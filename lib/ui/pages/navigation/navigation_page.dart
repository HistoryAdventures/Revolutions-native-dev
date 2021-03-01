import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:history_adventures/base/db/navigation_data.dart';
import 'package:history_adventures/base/functions/functions.dart';
import 'package:history_adventures/management/app_model.dart';

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage>
    with TickerProviderStateMixin {
  List<bool> showDetails;
  List<AnimationController> rotationControllers;
  AppModel appModel = AppModel();
  List<String> titles;
  List<List<List<String>>> contents;

  @override
  void initState() {
    AppFunctions.setDarkForeground();
    initializePageData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
    );
  }

  void initializePageData() {
    titles = data.keys.toList();
    contents = data.values.toList();
    showDetails = [false, false, false];
    rotationControllers = [
      AnimationController(
        duration: const Duration(milliseconds: 100),
        vsync: this,
      ),
      AnimationController(
        duration: const Duration(milliseconds: 100),
        vsync: this,
      ),
      AnimationController(
        duration: const Duration(milliseconds: 100),
        vsync: this,
      )
    ];
  }

  void selectSection(int index) {
    if (rotationControllers[index].status.index == 0)
      rotationControllers[index].forward(from: 0.0);
    else
      rotationControllers[index].animateBack(0.0);

    if (mounted)
      setState(() {
        showDetails[index] = !showDetails[index];
      });
  }

  Future<void> selectPage(int index) async {
    String pageData = await appModel.mainActions.getDataForPage(index: index);
    pageData = AppFunctions.removeLineBreaks(pageData);

    String jsSource = '''
      document.getElementById('page-show').innerHTML = '$pageData'; 
      goToPage(${index.toInt()});
    ''';

    Navigator.of(context).pop(jsSource);
  }

  Widget body() {
    return ColorfulSafeArea(
      color: Colors.black,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
            return;
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CupertinoButton(
                  child: Icon(Icons.chevron_left, color: Colors.grey),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: List.generate(
                    data.length,
                    (i) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [title(i), content(i)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget title(int i) {
    return CupertinoButton(
      onPressed: () {
        selectSection(i);
      },
      child: Row(
        children: [
          RotationTransition(
            child: Icon(Icons.arrow_right, color: Colors.black),
            turns: Tween(begin: 0.0, end: 0.25).animate(rotationControllers[i]),
          ),
          Text(
            titles[i],
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget content(int i) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      height: showDetails[i] ? contents[i].length * 45.0 : 0,
      padding: EdgeInsets.only(left: 50, right: 20),
      child: ListView(
        padding: EdgeInsets.zero,
        physics: NeverScrollableScrollPhysics(),
        children: List.generate(
          contents[i].length,
          (j) {
            return CupertinoButton(
              onPressed: () {
                selectPage(int.tryParse(contents[i][j].last));
              },
              padding: EdgeInsets.zero,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    contents[i][j].first,
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(
                    contents[i][j].last,
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}