import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ringtone_app/Screen/MainScreen.dart';
import 'package:ringtone_app/model/Users.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class Login extends StatefulWidget {

  bool autoLogin = true;

  Login(this.autoLogin);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new LoginState();
  }
}

class LoginState extends State<Login> {
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/plus.login',
  ],);
  final facebookLogin = FacebookLogin();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;
  String email;
  bool isLoading = false;
  bool isLoggedIn = false;
  FirebaseUser currentUser;
  DatabaseReference _users;

  @override
  void initState() {
    super.initState();
    _users = FirebaseDatabase.instance.reference().child('users');
    if(widget.autoLogin){
      //isSignedIn();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }


  void loadingTimeOut () {
    this.setState(() {
      isLoading = false;
    });
    Fluttertoast.showToast(msg: "Connection Failed");
  }

  void isSignedIn() async {
    this.setState(() {
      isLoading = true;
    });
    var timer;
    try {
      timer = Timer(Duration(seconds: 7), () => loadingTimeOut);
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {

        try {
          isLoggedIn = await facebookLogin.isLoggedIn;

          if(!isLoggedIn) {
            isLoggedIn = await googleSignIn.isSignedIn();
            GoogleSignInAccount googleUser = await googleSignIn.signIn();
            GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//            await autoLogin("Google", googleAuth.accessToken);
          } else {
            final result = await facebookLogin.logIn(['email', 'public_profile']);
//            await autoLogin("Facebook", result.accessToken.token);
          }
        } catch(_){
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: "Sign in fail");
        }
      }
    } on SocketException catch (_) {
      timer.cancel();
      print('not connected');
      this.setState(() {
        isLoading = false;
      });
    }

    this.setState(() {
      isLoading = false;
    });


    if (isLoggedIn) {
      timer.cancel();
//      Navigator.push(
//        context,
//        MaterialPageRoute(builder: (context) => MainScreen()),
//      );
    }

  }


  Future<Null> _loginWithGoogle() async {
    this.setState(() {
      isLoading = true;
    });
    var timer;
    prefs = await SharedPreferences.getInstance();
//    FirebaseUser firebaseUser;
    try {
      timer = Timer(Duration(seconds: 7), () => loadingTimeOut);
      GoogleSignInAccount googleUser = await googleSignIn.signIn();
      print("oke: ${googleUser.displayName}");
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseUser firebaseUser = (await firebaseAuth.signInWithCredential(credential)).user;
      Users user;


      if (firebaseUser != null) {
        final checkData = await _users.child(firebaseUser.uid).once();
        await prefs.setString('user_id', firebaseUser.uid);
        await prefs.setString('nickname', firebaseUser.displayName);
        await prefs.setString('photoUrl', firebaseUser.photoUrl);
        user = new Users();
        user.uid = firebaseUser.uid;
        user.name = firebaseUser.displayName;
        user.photoUrl = firebaseUser.photoUrl;
        if(checkData.value != null){
          await _users.child(firebaseUser.uid).update({
            'nickname': firebaseUser.displayName,
            'photoUrl': firebaseUser.photoUrl,
            'updatedAt': DateTime.now().millisecondsSinceEpoch.toString()
          });
        } else{
          await _users.child(firebaseUser.uid).set({
            'nickname': firebaseUser.displayName,
            'photoUrl': firebaseUser.photoUrl,
            'id': firebaseUser.uid,
            'createdAt': DateTime.now().millisecondsSinceEpoch.toString()
          });
        }
        Fluttertoast.showToast(msg: "Sign in success");
        this.setState(() {
          isLoading = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen(user)),
        );

//        Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: firebaseUser.uid)));
      } else {
        Fluttertoast.showToast(msg: "Sign in fail");
        this.setState(() {
          isLoading = false;
        });
      }



//      var check = await postAuthGG(googleAuth.accessToken);

//      print("Check: $check");
//
//      if (check) {
//        timer.cancel();
//        this.setState(() {
//          isLoading = false;
//        });
//
//        Fluttertoast.showToast(msg: "Sign in success");
//
//        Navigator.push(
//          context,
//          MaterialPageRoute(
//              builder: (context) => Router()),
//        );
//      } else {
//        timer.cancel();
//        this.setState(() {
//          isLoading = false;
//        });
//        Fluttertoast.showToast(msg: "Sign in fail");
//      }

    } catch(e) {
      timer.cancel();
      this.setState(() {
        isLoading = false;
      });
    }


  }

  Future<Null> _loginWithFaceBook() async {
    this.setState(() {
      isLoading = true;
    });
    var timer = Timer(Duration(seconds: 7), () => loadingTimeOut);
    prefs = await SharedPreferences.getInstance();

    final result = await facebookLogin
        .logIn(['email', 'public_profile']);
    if (result.status == FacebookLoginStatus.loggedIn) {
      FacebookAccessToken myToken = result.accessToken;

      try{
        AuthCredential credential =
        FacebookAuthProvider.getCredential(accessToken: myToken.token);

        final FirebaseUser firebaseUser = (await firebaseAuth.signInWithCredential(credential)).user;
        Users user;

        if (firebaseUser != null) {
          final checkData = await _users.child(firebaseUser.uid).once();
          await prefs.setString('user_id', firebaseUser.uid);
          await prefs.setString('nickname', firebaseUser.displayName);
          await prefs.setString('photoUrl', firebaseUser.photoUrl);
          user = new Users();
          user.uid = firebaseUser.uid;
          user.name = firebaseUser.displayName;
          user.photoUrl = firebaseUser.photoUrl;
          if(checkData.value != null){
            await _users.child(firebaseUser.uid).update({
              'nickname': firebaseUser.displayName,
              'photoUrl': firebaseUser.photoUrl,
              'updatedAt': DateTime.now().millisecondsSinceEpoch.toString()
            });
          } else{
            await _users.child(firebaseUser.uid).set({
              'nickname': firebaseUser.displayName,
              'photoUrl': firebaseUser.photoUrl,
              'id': firebaseUser.uid,
              'createdAt': DateTime.now().millisecondsSinceEpoch.toString()
            });
          }
          Fluttertoast.showToast(msg: "Sign in success");
          this.setState(() {
            isLoading = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MainScreen(user)),
          );

//        Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: firebaseUser.uid)));
        } else {
          Fluttertoast.showToast(msg: "Sign in fail");
          this.setState(() {
            isLoading = false;
          });
        }

      }catch(PlatformException){
        Fluttertoast.showToast(msg: "Sign in fail");
        this.setState(() {
          isLoading = false;
        });
      }
    } else {
      Fluttertoast.showToast(msg: "Sign in fail");
      this.setState(() {
        isLoading = false;
      });
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return new Scaffold(
//        backgroundColor: Color(0xff0C3040),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg_sign_in.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: new Stack(
            children: <Widget>[
              new ListView(
                children: <Widget>[
                  SizedBox(height: 150,),
                  new Stack(
                    children: <Widget>[
                      new Container(
                        width: width,
                        child: SafeArea(
                          child: Column(
                            children: <Widget>[
                              new Text(
                                'Sign in',
                                style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Comfortaa', fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 30,),
                              Center(
                                child: new FlatButton(
                                  onPressed: _loginWithFaceBook,
                                  child: new Container(
                                    width: width*8/10,
                                    height: ( width*8/10)*192/ 1020,
                                    decoration: new BoxDecoration(
                                      image: new DecorationImage(
                                        image: new AssetImage(
                                            "assets/images/khungFB.png"),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: new Stack(
                                      children: <Widget>[
                                        Container(
                                          padding: const EdgeInsets.only(
                                              left: 35.0, top: 15.0),
                                          child: new Image.asset(
                                            "assets/images/fbIcon.png",
                                            alignment: Alignment.centerLeft,
                                            width: width / 10,
                                            height: width / 18,
                                          ),
                                        ),
                                        Center(
                                          child: new Text(
                                            "Facebook",
                                            style: TextStyle(color: Colors.white, fontFamily: 'Comfortaa',),
                                          ),
                                        ),
                                        Container(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                  child: new FlatButton(
                                    onPressed: _loginWithGoogle,
                                    child: new Container(
                                      width: width*8/10,
                                      height: ( width*8/10)*192/ 1020,
                                      decoration: new BoxDecoration(
                                        image: new DecorationImage(
                                          image: new AssetImage(
                                              "assets/images/khungGG.png"),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: new Stack(
                                        children: <Widget>[
                                          Container(
                                            padding: const EdgeInsets.only(
                                                top: 15.0, left: 25.0),
                                            child: new Image.asset(
                                                "assets/images/ggIcon.png",
                                                width: width / 10,
                                                height: width / 18),
                                          ),
                                          Center(
                                            child: new Text(
                                              "Google",
                                              style: TextStyle(color: Colors.black, fontFamily: 'Comfortaa',),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                              SizedBox(height: 10,),
                              Center(
                                child: new FlatButton(
                                  onPressed: (() {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MainScreen(null)),
                                    );
                                  }),
                                  child: new Container(
                                      width: width*8/10,
                                      height: ( width*8/10)*192/ 1020,
                                      child:
                                      Container(
                                        padding: const EdgeInsets.only(
                                            top: 15.0, left: 25.0),
                                        child: Text(
                                          "Bỏ qua",
                                          style: TextStyle(color: Colors.white,fontSize: 16 ,fontFamily: 'Comfortaa',decoration: TextDecoration.underline,),
                                        ),
                                      )
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Positioned(
                child: isLoading
                    ? Container(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  color: Colors.white.withOpacity(0.8),
                )
                    : Container(),
              ),
            ],
          ),
        )
    );
  }
}
