import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:ringtone_app/Screen/HomeScreen.dart';
import 'package:ringtone_app/Screen/FavoriteScreen.dart';
import 'package:ringtone_app/Screen/Album/AbumScreen.dart';
import 'package:ringtone_app/Screen/MusicHome/PlayBottomScreen.dart';
import 'package:ringtone_app/Screen/Search/search_screen.dart';
import 'package:ringtone_app/store/AppStore.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:ringtone_app/blocs/global.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:ringtone_app/Screen/now_playing/now_playing_screen.dart';


class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MainScreenState();
  }
}


class MainScreenState extends State<MainScreen> {
  PageController pageController;
  PanelController panelController;

  bool isClick = false;
  int curentIndexNavBar = 0;

  void _onItemTapped(int index) {
    setState(() {
      curentIndexNavBar = index;
    });
    pageController.animateToPage(index,
        duration: Duration(milliseconds: 300), curve: Curves.ease);

  }

  void onPageChanged(int value) {
    setState(() {
      curentIndexNavBar = value;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController(initialPage: curentIndexNavBar,keepPage: true,viewportFraction: 1.0);
  }

  @override
  void dispose() {
    //pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final double _radius = 25.0;

    return WillPopScope(
      onWillPop: () {
        if (!panelController.isPanelClosed()) {
          panelController.close();
        } else {
          _showExitDialog();
        }
      },
      child: Scaffold(
          body: SlidingUpPanel(
            panel: ClipRRect(
                borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_radius),
                topRight: Radius.circular(_radius),
                ),
              child: NowPlayingScreen(controller: panelController),
            ),
            controller: panelController,
            minHeight: 110,
            maxHeight: MediaQuery.of(context).size.height,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(_radius),
              topRight: Radius.circular(_radius),
            ),
            collapsed: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_radius),
                topRight: Radius.circular(_radius),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.7,],
                colors: [Color(0xFFFD9D9D), Color(0xFF8A8A8A),],
                ),
              ),
              child: PlayBottomScreen(controller: panelController),
            ),
            body: Scaffold(
              body: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/bg.jpg"),
                        fit: BoxFit.cover,
                      )
                  ),
                  child:
                      Column(
                        children: <Widget>[
                          new Row(

                            children: <Widget>[
                              new Container(
                                width: width*2/5,
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(top:20.0,  bottom: 20),
                                child: GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      isClick = !isClick;
                                      store.isRingtone = false;
                                      store.isLocal = true;
                                    });
                                  },
                                  child: Text("Offline",style: TextStyle(fontSize: 20,
                                      fontWeight:FontWeight.bold,color: isClick? Colors.white: Color(0xff666666))),
                                ),
                              ),
                              new Container(
                                width: width*2/5,
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(top:0.0),
                                child: GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      isClick = !isClick;
                                    });
                                  },
                                  child: Text("Online",style: TextStyle(fontSize: 20,
                                      fontWeight:FontWeight.bold,color: isClick? Color(0xff666666): Colors.white)),
                                ),
                              ),
                              new Container(
                                  width: width/5,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(top:0.0),
                                  child: GestureDetector(
                                    onTap: ()=>  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SearchScreen(),
                                      ),
                                    ),
                                      child: Icon(Icons.search,color: Colors.white,size: 30,)
                                  )
                              )
                            ],
                          ),
                          BottomNavigationBar(
                            onTap:_onItemTapped,
                            backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
                            elevation: 4,
                            unselectedItemColor: Color(0xff666666),
                            selectedItemColor: Color(0xffFD9D9D),
                            currentIndex: curentIndexNavBar,
                            type: BottomNavigationBarType.fixed,
                            selectedLabelStyle: TextStyle(color: Colors.blue, fontSize: 15),
          //      unselectedLabelStyle: TextStyle(color: Colors.grey),
                            showUnselectedLabels: true,
          //      selectedIconTheme: IconThemeData(color: Colors.blue),
          //      unselectedIconTheme: IconThemeData(color: Colors.grey),
                            items: [
                              BottomNavigationBarItem(
                                icon: Icon(Icons.home, size: 30,),
                                title: Text('HOME'),
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.album, size: 30,),
                                title: Text('ALBUMS'),
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.favorite, size: 30,),
                                title: Text('FAVORITES'),
                              ),
                            ],
                          ),
                          Expanded(
                            child:  PageView(
                              physics: NeverScrollableScrollPhysics(),
                              controller: pageController,
                              onPageChanged: onPageChanged,
                              children: <Widget>[
                                HomeScreen(!isClick),
                                AlbumsScreen(!isClick),
                                FavoriteScreen(),
                                ]),
                          )
                        ],
                      )

            ),
          )
        )
      )
    );
  }
  void _showExitDialog() {
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'BlackPink Ringtones',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          content: Text(
            "If you like this app, please take a little bit of your time to review it !\nIt really helps us and it shouldn\'t take you more than one minute.",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Color(0xFFDF5F9D),
              onPressed: () {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                _globalBloc.dispose();
              },
              child: Text("EXIT"),
            ),
            FlatButton(
              textColor: Color(0xFFDF5F9D),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("CANCEL"),
            ),
            FlatButton(
              textColor: Color(0xFFDF5F9D),
              onPressed: () async {
                RateMyApp rateMyApp = RateMyApp();
                await rateMyApp.launchStore();
              },
              child: Text("RATE"),
            ),
          ],
        );
      },
    );
  }
}