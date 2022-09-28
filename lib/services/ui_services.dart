import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../constants/basic.dart';
import '../constants/ui.dart';
import '../widgets/custom_dialog_box.dart';
import '../widgets/custom_divider.dart';
import '../widgets/custom_sized_box.dart';
import '../widgets/top_back_bar.dart';
import 'auth_provider_widget.dart';
import 'auth_service.dart';
import 'communications.dart';
import 'navigation.dart';
import 'storage_services.dart';

class BubbleTabIndicator extends Decoration {
  final double indicatorHeight;
  final Color indicatorColor;
  final double indicatorRadius;
  // ignore: annotate_overrides
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry insets;
  final TabBarIndicatorSize tabBarIndicatorSize;

  const BubbleTabIndicator({
    this.indicatorHeight = 20.0,
    this.indicatorColor = Colors.greenAccent,
    this.indicatorRadius = 100.0,
    this.tabBarIndicatorSize = TabBarIndicatorSize.label,
    this.padding = const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
    this.insets = const EdgeInsets.symmetric(horizontal: 5.0),
  });

  @override
  Decoration lerpFrom(Decoration a, double t) {
    if (a is BubbleTabIndicator) {
      return BubbleTabIndicator(
        padding: EdgeInsetsGeometry.lerp(a.padding, padding, t),
        insets: EdgeInsetsGeometry.lerp(a.insets, insets, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  Decoration lerpTo(Decoration b, double t) {
    if (b is BubbleTabIndicator) {
      return BubbleTabIndicator(
        padding: EdgeInsetsGeometry.lerp(padding, b.padding, t),
        insets: EdgeInsetsGeometry.lerp(insets, b.insets, t),
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  // ignore: library_private_types_in_public_api
  _BubblePainter createBoxPainter([VoidCallback onChanged]) {
    return _BubblePainter(this, onChanged);
  }
}

class _BubblePainter extends BoxPainter {
  _BubblePainter(this.decoration, VoidCallback onChanged) : super(onChanged);

  final BubbleTabIndicator decoration;

  double get indicatorHeight => decoration.indicatorHeight;
  Color get indicatorColor => decoration.indicatorColor;
  double get indicatorRadius => decoration.indicatorRadius;
  EdgeInsetsGeometry get padding => decoration.padding;
  EdgeInsetsGeometry get insets => decoration.insets;
  TabBarIndicatorSize get tabBarIndicatorSize => decoration.tabBarIndicatorSize;

  Rect _indicatorRectFor(Rect rect, TextDirection textDirection) {
    Rect indicator = padding.resolve(textDirection).inflateRect(rect);

    if (tabBarIndicatorSize == TabBarIndicatorSize.tab) {
      indicator = insets.resolve(textDirection).deflateRect(rect);
    }

    return Rect.fromLTWH(
      indicator.left,
      indicator.top,
      indicator.width,
      indicator.height,
    );
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    final Rect rect = Offset(
            offset.dx, (configuration.size.height / 2) - indicatorHeight / 2) &
        Size(configuration.size.width, indicatorHeight);
    final TextDirection textDirection = configuration.textDirection;
    final Rect indicator = _indicatorRectFor(rect, textDirection);
    final Paint paint = Paint();
    paint.color = indicatorColor;
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromRectAndRadius(indicator, Radius.circular(indicatorRadius)),
        paint);
  }
}

enum AuthFormType { signIn, signUp, reset }

class UIServices {
  Future<dynamic> showDatSheet(
    Widget sheet,
    bool willThisThingNeedScrolling,
    BuildContext context, {
    double height,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: willThisThingNeedScrolling,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: height ?? MediaQuery.of(context).size.height * 0.9,
            child: StatefulBuilder(builder: (context, setIt) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      NavigationService().pop();
                    },
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).canvasColor,
                      child: Icon(
                        Icons.close,
                      ),
                    ),
                  ),
                  CustomSizedBox(
                    sbSize: SBSize.smallest,
                    height: true,
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          16,
                        ),
                        topRight: Radius.circular(
                          16,
                        ),
                      ),
                      child: Container(
                        color: Theme.of(context).canvasColor,
                        child: sheet,
                      ),
                    ),
                  )
                ],
              );
            }),
          ),
        );
      },
    );
  }

  ImageProvider<Object> getImageProvider(
    dynamic asset,
  ) {
    return asset == null
        ? null
        : asset is File
            ? FileImage(asset)
            : asset.toString().trim().contains(
                      "assets/images",
                    )
                ? AssetImage(
                    asset,
                  )
                : CachedNetworkImageProvider(
                    asset,
                  );
  }

  DecorationImage decorationImage(
    dynamic asset,
    bool darken,
  ) {
    return asset == null
        ? null
        : DecorationImage(
            image: asset is File
                ? FileImage(asset)
                : asset.toString().trim().contains(
                          "assets/images",
                        )
                    ? AssetImage(
                        asset,
                      )
                    : CachedNetworkImageProvider(
                        asset,
                      ),
            fit: BoxFit.cover,
            colorFilter: darken
                ? ColorFilter.mode(
                    Colors.black.withOpacity(0.6),
                    BlendMode.darken,
                  )
                : null,
          );
  }

  showLoginSheet(
    AuthFormType initialAuthFormType,
    Function(String id) doAfterWards,
    BuildContext context,
  ) {
    showDatSheet(
      LoginSheet(
        initialAuthFormType: initialAuthFormType,
        doAfterWards: doAfterWards,
      ),
      true,
      context,
    );
  }
}

class LoginSheet extends StatefulWidget {
  final AuthFormType initialAuthFormType;
  final Function(String) doAfterWards;

  LoginSheet({
    Key key,
    @required this.initialAuthFormType,
    @required this.doAfterWards,
  }) : super(key: key);

  @override
  State<LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<LoginSheet> {
  AuthFormType authFormType;
  TextEditingController userNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool processing = false;
  final formKey = GlobalKey<FormState>();
  String _email, _password, _warning, _phoneNumber;
  String _username = "$capitalizedAppName User";
  bool visible = false;
  String _switchButton, _submitButtonText;
  bool _showForgotPassword = false;

  @override
  void initState() {
    authFormType = widget.initialAuthFormType;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;
    if (authFormType == AuthFormType.signIn) {
      _switchButton = "Create A New Account";
      _submitButtonText = "Sign In";
      _showForgotPassword = true;
    } else if (authFormType == AuthFormType.reset) {
      _switchButton = "Return to Sign In";
      _showForgotPassword = false;
      _submitButtonText = "Submit";
    } else {
      _switchButton = "Have an Account? Sign In";
      _showForgotPassword = false;
      _submitButtonText = "Sign Up";
    }

    return Scaffold(
      body: Column(
        children: [
          BackBar(
            icon: null,
            onPressed: null,
            text: "",
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          authFormType == AuthFormType.signIn
                              ? "Sign In"
                              : authFormType == AuthFormType.signUp
                                  ? "Create Account"
                                  : "Reset Password",
                          style: TextStyle(
                            fontSize: 30,
                            // color: altColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          ".",
                          style: TextStyle(color: primaryColor, fontSize: 40),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 0.002 * screenheight,
                  ),
                  _warning != null
                      ? Container(
                          color: Colors.red,
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.error_outline,
                                color: Colors.white,
                              ),
                              CustomSizedBox(
                                sbSize: SBSize.smallest,
                                height: false,
                              ),
                              Expanded(
                                child: Text(
                                  _warning,
                                  maxLines: 5,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.white),
                                onPressed: () {
                                  if (mounted) {
                                    setState(() {
                                      _warning = null;
                                    });
                                  }
                                },
                              )
                            ],
                          ),
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 0.002 * screenheight,
                  ),
                  Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (authFormType == AuthFormType.signUp)
                            TextFormField(
                              validator: UsernameValidator.validate,
                              style: TextStyle(
                                fontSize: 14,
                              ),
                              controller: userNameController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                hintText: "Username",
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 0,
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(10),
                              ),
                              onSaved: (value) => _username = value.trim(),
                            ),
                          if (authFormType != AuthFormType.reset)
                            CustomSizedBox(
                              sbSize: SBSize.small,
                              height: true,
                            ),
                          TextFormField(
                            validator: EmailValidator.validate,
                            style: TextStyle(
                              fontSize: 14,
                            ),
                            textInputAction: authFormType == AuthFormType.reset
                                ? TextInputAction.send
                                : TextInputAction.next,
                            decoration: InputDecoration(
                              suffixIcon: Icon(
                                Icons.email,
                              ),
                              hintText: "Email",
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: Colors.grey,
                                width: 0,
                              )),
                              contentPadding: EdgeInsets.all(10),
                            ),
                            onSaved: (value) => _email = value.trim(),
                          ),
                          CustomSizedBox(
                            sbSize: SBSize.small,
                            height: true,
                          ),
                          if (authFormType == AuthFormType.signUp)
                            TextFormField(
                              validator: PhoneNumberValidator.validate,
                              textInputAction: TextInputAction.next,
                              onSaved: (value) => _phoneNumber = value.trim(),
                              style: TextStyle(
                                fontSize: 14,
                              ),
                              controller: phoneNumberController,
                              decoration: InputDecoration(
                                suffixIcon: Icon(
                                  Icons.phone,
                                ),
                                hintText: "Phone Number",
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 0,
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(10),
                              ),
                            ),
                          if (authFormType == AuthFormType.signUp)
                            CustomSizedBox(
                              sbSize: SBSize.small,
                              height: true,
                            ),
                          if (authFormType != AuthFormType.reset)
                            TextFormField(
                              controller: passwordController,
                              validator: PasswordValidator.validate,
                              textInputAction: TextInputAction.next,
                              style: TextStyle(
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    !visible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    if (mounted) {
                                      setState(() {
                                        visible = !visible;
                                      });
                                    }
                                  },
                                ),
                                hintText: "Password",
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey, width: 0)),
                                contentPadding: EdgeInsets.all(10),
                              ),
                              onSaved: (value) => _password = value.trim(),
                              obscureText: !visible,
                            ),
                          CustomSizedBox(
                            sbSize: SBSize.small,
                            height: true,
                          ),
                          if (authFormType == AuthFormType.signUp)
                            TextFormField(
                              textInputAction: TextInputAction.next,
                              style: TextStyle(
                                fontSize: 14,
                              ),
                              controller: confirmPasswordController,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    !visible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    if (mounted) {
                                      setState(() {
                                        visible = !visible;
                                      });
                                    }
                                  },
                                ),
                                hintText: "Confirm Password",
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey, width: 0)),
                                contentPadding: EdgeInsets.all(10),
                              ),
                              obscureText: !visible,
                            ),
                          if (authFormType != AuthFormType.reset)
                            Column(
                              children: [
                                CustomSizedBox(
                                  sbSize: SBSize.smallest,
                                  height: true,
                                ),
                                CustomDivider(),
                                ListTile(
                                  title: Text(
                                    "By signing in, you agree to the $capitalizedAppName usage terms and conditions",
                                  ),
                                ),
                                CustomDivider(),
                                CustomSizedBox(
                                  sbSize: SBSize.normal,
                                  height: true,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    
                                    // launchUrl(
                                    //   Uri.parse(
                                    //     simeonWebsite,
                                    //   ),
                                    // );
                                  },
                                  child: Text(
                                    "Terms and conditions",
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          CustomSizedBox(
                            sbSize: SBSize.normal,
                            height: true,
                          ),
                          SizedBox(
                            height: 40,
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (processing) {
                                  CommunicationServices().showSnackBar(
                                      "Just a sec. Please wait.. (You can tap here to cancel and try again)",
                                      context,
                                      behavior: SnackBarBehavior.floating,
                                      buttonText: "Cancel", whatToDo: () {
                                    if (mounted) {
                                      setState(() {
                                        processing = false;
                                      });
                                    }
                                  });
                                } else {
                                  if (authFormType == AuthFormType.signUp) {
                                    if (passwordController.text.trim().isEmpty) {
                                      final form = formKey.currentState;

                                      form.save();
                                      form.validate();
                                    } else {
                                      if (confirmPasswordController.text
                                          .trim()
                                          .isEmpty) {
                                        CommunicationServices().showSnackBar(
                                          "Please confirm your password",
                                          context,
                                          behavior: SnackBarBehavior.floating,
                                        );
                                      } else {
                                        if (confirmPasswordController.text
                                                .trim() ==
                                            passwordController.text.trim()) {
                                          doIt();
                                        } else {
                                          CommunicationServices().showSnackBar(
                                            "Your password doesn't match. Please check on them.",
                                            context,
                                            behavior: SnackBarBehavior.floating,
                                          );
                                        }
                                      }
                                    }
                                  } else {
                                    doIt();
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: standardBorderRadius,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: processing
                                    ? SpinKitWave(
                                        color: Colors.white,
                                        size: 25,
                                      )
                                    : Text(
                                        _submitButtonText,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                          ),
                          if (_showForgotPassword)
                            Container(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(color: primaryColor),
                                ),
                                onPressed: () {
                                  if (mounted) {
                                    setState(() {
                                      authFormType = AuthFormType.reset;
                                    });
                                  }
                                },
                              ),
                            ),
                          TextButton(
                            child: Text(
                              _switchButton,
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 18,
                              ),
                            ),
                            onPressed: () {
                              if (authFormType == AuthFormType.reset) {
                                formKey.currentState.reset();
                                if (mounted) {
                                  setState(() {
                                    authFormType = AuthFormType.signIn;
                                  });
                                }
                              } else {
                                if (authFormType == AuthFormType.signIn) {
                                  formKey.currentState.reset();
                                  if (mounted) {
                                    setState(() {
                                      authFormType = AuthFormType.signUp;
                                    });
                                  }
                                } else {
                                  formKey.currentState.reset();
                                  if (mounted) {
                                    setState(() {
                                      authFormType = AuthFormType.signIn;
                                    });
                                  }
                                }
                              }
                            },
                          ),
                        ], //buildInputs() + buildButtons(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  doIt() async {
    final form = formKey.currentState;
    form.save();
    if (form.validate()) {
      form.save();
      try {
        if (mounted) {
          setState(() {
            processing = true;
          });
        }
        final auth = AuthProvider.of(context).auth;

        if (authFormType == AuthFormType.signIn) {
          signIn();
        } else if (authFormType == AuthFormType.reset) {
          await auth.sendPasswordResetEmail(_email);
          _warning =
              "If there is an account linked to $_email, A password Reset link has been sent to $_email";
          if (mounted) {
            setState(
              () {
                authFormType = AuthFormType.signIn;
              },
            );
          }
        } else if (authFormType == AuthFormType.signUp) {
          signUp();
        }
      } catch (e) {
        processing = false;

        if (mounted) {
          setState(() {
            _warning = e.toString();
          });
        }
      }
    }
  }

  signUp() async {
    final auth = AuthProvider.of(context).auth;

    await auth
        .createUserWithEmailAndPassword(_email, _password, _username)
        .then((value) async {
      String token = await FirebaseMessaging.instance.getToken();

      StorageServices().createNewUser(
        userName: _username.trim(),
        images: [],
        phoneNumber: _phoneNumber,
        token: token,
        uid: value,
        email: _email.trim(),
      );

      AuthProvider.of(context).auth.startVerifyingEmail();

      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        CommunicationServices().showToast(
          "You need to give permissions to send notifications or else you'll miss out on a lot.",
          Colors.red,
        );
      }

      Navigator.of(context).pop();

      showDialog(
          context: context,
          builder: (context) {
            return CustomDialogBox(
              bodyText:
                  "We have sent you an email on your email address $_email to verify the email.\nPlease tap on the link in the email to verify your email address\n\nIf you can't see the email, try checking your spam folder.",
              buttonText: "Done",
              onButtonTap: () {
                AuthProvider.of(context).auth.reloadAccount(context);
              },
              showOtherButton: true,
            );
          });

      CommunicationServices().showToast(
        "Successfully created your account",
        primaryColor,
      );

      widget.doAfterWards(value);
    }).timeout(
            Duration(
              seconds: 10,
            ), onTimeout: () {
      handleError(
        "There was an error logging you in. Either your internet isn't connected, or you're trying to sign up using an email that's already been used.",
      );
    }).catchError((v) {
      handleError(
        v.toString(),
      );
    });
  }

  handleError(dynamic error) {
    processing = false;

    if (mounted) {
      setState(() {
        _warning = error.toString();
      });
    }
  }

  signIn() async {
    final auth = AuthProvider.of(context).auth;

    await auth
        .signInWithEmailAndPassword(_email, _password)
        .then((value) async {
      FirebaseMessaging.instance.getToken().then(
        (token) {
          StorageServices().updateFCMToken(
            value,
            token,
          );
        },
      );

      StorageServices().notifyAboutLogin(value);

      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        CommunicationServices().showToast(
          "You need to give permissions to send notifications or else you'll miss out on a lot.",
          Colors.red,
        );
      }

      Navigator.of(context).pop();

      CommunicationServices().showToast(
        "Successfully signed in",
        primaryColor,
      );

      widget.doAfterWards(value);
    }).timeout(
            Duration(
              seconds: 10,
            ), onTimeout: () {
      handleError(
        "There was an error loggin you in. Either your internet isn't connected, or you're trying to Sign into an account that doesn't exist.",
      );
    }).catchError((v) {
      handleError(
        v.toString(),
      );
    });
  }
}

class MySliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  MySliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).canvasColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(MySliverAppBarDelegate oldDelegate) {
    return false;
  }
}
