import 'dart:async';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:history_adventures/base/functions/functions.dart';
import 'package:history_adventures/base/images/images.dart';
import 'package:history_adventures/management/app_model.dart';
import 'package:history_adventures/ui/pages/navigation/navigation_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  InAppWebViewController controller;
  AppModel appModel = AppModel();
  int selectedIndex;
  bool showDetails;
  Timer timer;
  double pageItemHeight;
  double pageItemWidth;
  List<Widget> pages = [];
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int doubleTapCount = 0;
  double screenWidth;
  double screenHeight;
  double safeAreaTop;
  double safeAreaBottom;
  double contentHeight;
  bool doubleTapIconAlreadyShown = false;
  Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;
  bool webViewScrollEnabled = true;
  bool snackBarIsOpen = false;
  bool ignorePointer = false;

  @override
  void initState() {
    AppFunctions.setDarkForeground();
    selectedIndex = 0;
    showDetails = false;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    safeAreaTop = MediaQuery.of(context).padding.top;
    safeAreaBottom = MediaQuery.of(context).padding.bottom;
    contentHeight = screenHeight - safeAreaTop - safeAreaBottom;
    pageItemHeight = screenHeight / 5;
    pageItemWidth = pageItemHeight * 0.7;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(key: scaffoldKey, body: body());
  }

  // funtions

  // get html data for the current selected page and show it
  Future<void> getDataForPage({
    int index = 0,
    InAppWebViewController controller,
  }) async {
    print(selectedIndex);

    String jsSource = '''
      goToPage(${index.toInt()});
      var videos = document.getElementsByTagName('video');
      for (i = 0; i < videos.length; i++) {
        videos[i].autoplay = false;
      }
    ''';

    print('jsSource $pageItemHeight');

    var result = await controller?.evaluateJavascript(source: jsSource);
    if (index == 2) showDoubleTapIcon();

    if (result != null) {
      setState(() {
        showDetails = false;
      });
      enableWebViewScroll();
    }
  }

  void initializeTimer() {
    if (timer != null) {
      timer.cancel();
    }
    timer = Timer(Duration(seconds: 5), () {
      setState(() {
        enableWebViewScroll();
        showDetails = false;
      });
    });
  }

  Future<void> doubleTapAction() async {
    print('doubleTapAction');
    // get the value of "popupOpened" js variable
    await callJsHandler();

    // check if popup is closed then show the bottom navigation list
    addJsHandler();
  }

  Future<void> callJsHandler() async {
    await controller?.evaluateJavascript(source: '''
      window.flutter_inappwebview.callHandler("popupOpened", popupOpened);
    ''');
  }

  void addJsHandler() {
    controller?.addJavaScriptHandler(
      handlerName: 'popupOpened',
      callback: (value) {
        print('popupOpened: ${value.first}');
        // should show navigation bars only when there is not opened popup
        if (value.first == false) {
          setState(() {
            showDetails = !showDetails;
          });
          if (showDetails)
            initializeTimer();
          else
            enableWebViewScroll();
        } else {
          setState(() {
            enableWebViewScroll();
            showDetails = false;
          });
        }
      },
    );
  }

  void showDoubleTapIcon() {
    // wait page to load then show the icon
    Future.delayed(Duration(milliseconds: doubleTapIconAlreadyShown ? 0 : 500),
        () {
      if (!doubleTapIconAlreadyShown) doubleTapIconAlreadyShown = true;
      controller.evaluateJavascript(source: '''
        var howToUse = document.getElementsByClassName('how-to-use');
        var mb5 = document.getElementsByClassName('mb-5');
        mb5[0].classList.remove('mb-5');
        var container = document.createElement('DIV');
        container.className = 'row px-2 px-sm-4 mb-5';
        container.innerHTML = '<div class="col-3"> <img class="book-imgs" src="../assets/img/double_tap.png"> </div> <div class="col-8 d-flex align-items-center">  <div>Double tap the screen to access Table Of Contents</div> </div>';
        howToUse[0].appendChild(container);
      ''');
    });
  }

  void disableWebViewScroll() {
    print('disable');
    webViewScrollEnabled = false;
    controller.evaluateJavascript(
        source: 'tuchSpaceNumber = ${MediaQuery.of(context).size.width};');
  }

  void enableWebViewScroll() {
    print('enable');
    webViewScrollEnabled = true;
    controller.evaluateJavascript(source: 'tuchSpaceNumber = 80;');
  }

  Widget body() {
    return ColorfulSafeArea(
      color: Colors.black,
      child: GestureDetector(
        onDoubleTap: doubleTapAction,
        child: Stack(
          children: [
            Align(alignment: Alignment.center, child: content()),
            Align(alignment: Alignment.bottomCenter, child: bottomNavigation()),
            // Align(alignment: Alignment.topLeft, child: topNavigation()),
          ],
        ),
      ),
    );
  }

  Widget content() {
    return Column(
      children: [
        topNavigation(),
        Expanded(
          child: GestureDetector(
            child: InAppWebView(
              onConsoleMessage: (_, consoleMessage) {
                print('console message: ${consoleMessage.message}');

                // 'slide right [x]' and 'slide left [x]' are console messages from javascript, [x] is current page.
                // Should show 'double tap' icon on the second page.
                if ((consoleMessage.message == 'slide right 2' ||
                    consoleMessage.message == 'slide left 2'))
                  showDoubleTapIcon();
              },
              initialUrl:
                  'https://revolutions.historyadventures.app/new_revolutions/#mobile',
              initialOptions: InAppWebViewGroupOptions(
                ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true),
              ),
              onProgressChanged: (_controller, progress) async {
                print(progress);
              },
              onWebViewCreated: (_controller) async {
                controller = _controller;
              },
              onLoadStop: (_controller, url) async {
                // call js handler functions
                await doubleTapAction();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomNavigation() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 80),
      height: showDetails ? pageItemHeight : 0,
      color: Colors.black.withOpacity(0.5),
      padding: EdgeInsets.all(1),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          return;
        },
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            Container(
              height: pageItemHeight,
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  initializeTimer();

                  if (notification is ScrollStartNotification) {
                    disableWebViewScroll();
                  }

                  return;
                },
                child: ListView.builder(
                  physics: ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: 81,
                  itemBuilder: (context, index) => pageItem(index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget pageItem(int index) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      pressedOpacity: 0.9,
      onPressed: () async {
        setState(() {
          selectedIndex = index;
        });

        await getDataForPage(index: index, controller: controller);
      },
      child: Container(
        width: pageItemWidth,
        height: pageItemHeight,
        margin: EdgeInsets.symmetric(horizontal: 0.5),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.pageThumbnailPath(index)),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget topNavigation() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 80),
      height: showDetails ? 36 : 0,
      decoration: BoxDecoration(
        color: Colors.white,
        border: !showDetails
            ? null
            : Border(
                bottom: BorderSide(
                width: 1,
                color: Colors.black.withOpacity(0.5),
              )),
      ),
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.symmetric(horizontal: 10),
                minSize: 0,
                child: Icon(Icons.list, color: Colors.grey, size: 32),
                onPressed: () async {
                  String jsSource = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return NavigationPage();
                    }),
                  );
                  AppFunctions.setDarkForeground();
                  if (jsSource != null)
                    controller.evaluateJavascript(source: jsSource);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
