import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:ringtone_app/Screen/HomeScreen.dart';
import 'package:ringtone_app/Screen/FavoriteScreen.dart';
import 'package:ringtone_app/Screen/Album/AbumScreen.dart';
import 'package:ringtone_app/Screen/Login/LoginScreen.dart';
import 'package:ringtone_app/Screen/MusicHome/PlayBottomScreen.dart';
import 'package:ringtone_app/Screen/Search/search_screen.dart';
import 'package:ringtone_app/constant/app_constant.dart';
import 'package:ringtone_app/model/Users.dart';
import 'package:ringtone_app/store/AppStore.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:ringtone_app/blocs/global.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:ringtone_app/Screen/now_playing/now_playing_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';


const platform = const MethodChannel('com.vn.ringtone_app');

class MainScreen extends StatefulWidget {
  Users user;

  MainScreen(this.user);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MainScreenState();
  }
}


class MainScreenState extends State<MainScreen> {
  PageController pageController;
  PanelController panelController;

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FacebookLogin facebookLogin = FacebookLogin();
  bool isLoading = false;

  bool isClick = false;
  int curentIndexNavBar = 0;

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

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

  Future<Null> handleSignOut() async {
    this.setState(() {
      isLoading = true;
    });
    await FirebaseAuth.instance.signOut();
    bool fb = await facebookLogin.isLoggedIn;
    bool gg = await googleSignIn.isSignedIn();
    if (fb) {
      await facebookLogin.logOut();
    }
    if (gg) {
      await googleSignIn.disconnect();
      await googleSignIn.signOut();
    }
    this.setState(() {
      isLoading = false;
    });
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Login(false)),
            (Route<dynamic> route) => false);
  }


  Drawer _buildDrawer(context, width, height) {
    return new Drawer(
        child: new Stack(
          children: <Widget>[
            new Container(
              height: height,
              color: COLOR_MAIN,
              child: ListView(
                children: <Widget>[
                  new Container(
                    height: height / 50,
                    color: COLOR_MAIN,
                  ),
                  Container(
                    color: COLOR_MAIN,
                    child: Center(
                        child: Container(
                          color: COLOR_MAIN,
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(height/12)),
                            child: widget.user == null ? new Icon(Icons.person, size: height/6, color: Colors.white,):
                            CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue),
                                ),
                                width: width / 6,
                                height: width / 6,
                              ),
                              imageUrl: widget.user.photoUrl,
                              width: width / 6,
                              height: width / 6,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )),
                  ),
                  new Container(
                    color: COLOR_MAIN,
                    child: new Column(
                      children: <Widget>[
                        new SizedBox(
                          height: height / 100,
                        ),
                        new Container(
                          child: new Text(
                            widget.user != null ? widget.user.name : "",
                            style: new TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'Comfortaa'),
                          ),
                        ),
                        new Divider(
                          color: Colors.white,
                          indent: 0.0,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          child: GestureDetector(
                            onTap: () {
                              if(widget.user != null){
                                handleSignOut();
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Login(true)),
                                );
                              }
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                    margin: EdgeInsets.only(left: 10, right: 10),
                                    child: Icon(Icons.rate_review,size: 25,)
                                ),
                                Container(
                                  child: Text(
                                    widget.user != null ? "Log out" : "Log In",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontFamily: 'Comfortaa'),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          child: GestureDetector(
                            onTap: () {
                              platform.invokeMethod('moreApp');
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                    margin: EdgeInsets.only(left: 10, right: 10),
                                    child: Icon(Icons.more,size: 25,)

                                ),
                                Container(
                                  child: Text(
                                    "More App",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontFamily: 'Comfortaa'),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              child: isLoading
                  ? Container(
                child: Center(
                  child: CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.blue)),
                ),
                color: Colors.white.withOpacity(0.8),
              )
                  : Container(),
            )
          ],
        ));
  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final double _radius = 25.0;

    return WillPopScope(
      onWillPop: () {
        print("------------------------oke");
        _showExitDialog();
//        if (!panelController.isPanelClosed()) {
//          panelController.close();
//        } else {
//
//          _showExitDialog();
//        }
      },
      child: Scaffold(
          key: _scaffoldKey,
          drawer: _buildDrawer(context, width, height),
          body: SafeArea(
            child: SlidingUpPanel(
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
                              Container(
                                width: width/6,
                                  child: new IconButton(
                                      icon: Icon(Icons.menu, color: Colors.white, size: 30,),
                                      onPressed: (){
                                        _scaffoldKey.currentState.openDrawer();
                                      })
                              ),
                              new Container(
                                width: width*2/6,
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
                                width: width*2/6,
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
                                  width: width/6,
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
            ),
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