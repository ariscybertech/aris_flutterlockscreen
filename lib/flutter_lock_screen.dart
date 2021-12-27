library flutter_lock_screen;

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef void DeleteCode();
typedef Future<bool> PassCodeVerify(List<int> passcode);

class LockScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback fingerFunction;
  final Widget buttonChild;
  final bool verifyButtonEnabled;
  final bool fingerVerify;
  final String title;
  final TextStyle titleTextStyle;
  final Widget subtitle;
  final Color titleIconColor;
  final int passLength;
  final bool showWrongPassDialog;
  final bool showFingerPass;
  final String wrongPassTitle;
  final String wrongPassContent;
  final String wrongPassCancelButtonText;
  final String bgImage;
  final String numFontFamily;
  final Color numColor;
  final Color numBackgroundColor;
  final Color numBorderColor;
  final String fingerPrintImage;
  final Color borderColor;
  final Color foregroundColor;
  final PassCodeVerify passCodeVerify;

  LockScreen({
    this.onSuccess,
    this.title,
    this.titleTextStyle = const TextStyle(
      color: Colors.white,
      fontFamily: "Open Sans",
    ),
    this.subtitle,
    this.titleIconColor = Colors.white,
    this.borderColor,
    this.foregroundColor = Colors.transparent,
    this.passLength,
    this.passCodeVerify,
    this.fingerFunction,
    this.fingerVerify = false,
    this.showFingerPass = false,
    this.bgImage,
    this.numFontFamily = "Open Sans",
    this.numColor = Colors.black,
    this.numBackgroundColor = Colors.white,
    this.numBorderColor = Colors.white,
    this.fingerPrintImage,
    this.showWrongPassDialog = false,
    this.wrongPassTitle,
    this.wrongPassContent,
    this.wrongPassCancelButtonText,
    this.buttonChild,
    this.verifyButtonEnabled = false,
  })  : assert(subtitle != null),
        assert(passLength <= 8),
        assert(bgImage != null),
        assert(borderColor != null),
        assert(foregroundColor != null),
        assert(passCodeVerify != null),
        assert(onSuccess != null);

  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  var _currentCodeLength = 0;
  var _inputCodes = <int>[];
  var _currentState = 0;
  Color circleColor = Colors.white;

  void _lockPortraitMode() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void initState() {
    _lockPortraitMode();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _onCodeClick(int code) {
    if (_currentCodeLength < widget.passLength) {
      setState(() {
        _currentCodeLength++;
        _inputCodes.add(code);
      });

      if (_currentCodeLength == widget.passLength) {
        if (widget.buttonChild == null) _verifyPassCode();
      }
    }
  }

  _fingerPrint() {
    if (widget.fingerVerify) {
      widget.onSuccess();
    }
  }

  _deleteCode() {
    setState(() {
      if (_currentCodeLength > 0) {
        _currentState = 0;
        _currentCodeLength--;
        _inputCodes.removeAt(_currentCodeLength);
      }
    });
  }

  _deleteAllCode() {
    setState(() {
      if (_currentCodeLength > 0) {
        _currentState = 0;
        _currentCodeLength = 0;
        _inputCodes.clear();
      }
    });
  }

  _verifyPassCode() {
    widget.passCodeVerify(_inputCodes).then(
      (onValue) {
        if (onValue) {
          setState(() {
            _currentState = 1;
          });
          new Timer(new Duration(milliseconds: 200), () {
            widget.onSuccess();
          });
        } else {
          _currentState = 2;
          new Timer(new Duration(milliseconds: 1000), () {
            setState(() {
              _currentState = 0;
              _currentCodeLength = 0;
              _inputCodes.clear();
            });
          });
          if (widget.showWrongPassDialog) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return Center(
                  child: AlertDialog(
                    title: Text(
                      widget.wrongPassTitle,
                      style: TextStyle(color: Colors.black, fontFamily: "Open Sans"),
                    ),
                    content: Text(
                      widget.wrongPassContent,
                      style: TextStyle(fontFamily: "Open Sans"),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          widget.wrongPassCancelButtonText,
                          style: TextStyle(color: Colors.blue),
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 200), () {
      _fingerPrint();
    });
    return Scaffold(
      backgroundColor: widget.numBackgroundColor,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: widget.numBackgroundColor,
              ),
              child: Stack(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(_currentState != 1 ? Icons.lock : Icons.lock_open,
                              size: 36, color: widget.titleIconColor),
                          SizedBox(
                            height: 20,
                          ),
                          CodePanel(
                            codeLength: widget.passLength,
                            currentLength: _currentCodeLength,
                            borderColor: widget.borderColor,
                            foregroundColor: widget.foregroundColor,
                            deleteCode: _deleteCode,
                            fingerVerify: widget.fingerVerify,
                            status: _currentState,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          widget.subtitle,
                        ],
                      ),
                    ),
                  ),
                  widget.showFingerPass
                      ? Positioned(
                          top: MediaQuery.of(context).size.height / (Platform.isIOS ? 4 : 5),
                          left: 20,
                          bottom: 10,
                          child: GestureDetector(
                            onTap: () {
                              widget.fingerFunction();
                            },
                            child: Image.asset(
                              widget.fingerPrintImage,
                              height: 40,
                              width: 40,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 7,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 850, maxWidth: 400),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * .1,
                        top: 0,
                        right: MediaQuery.of(context).size.width * .1),
                    child: NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overscroll) {
                        overscroll.disallowGlow();
                      },
                      child: GridView.count(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        crossAxisCount: 3,
                        childAspectRatio: 1.1,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        padding: EdgeInsets.only(bottom: 30),
                        children: <Widget>[
                          buildContainerCircle(1),
                          buildContainerCircle(2),
                          buildContainerCircle(3),
                          buildContainerCircle(4),
                          buildContainerCircle(5),
                          buildContainerCircle(6),
                          buildContainerCircle(7),
                          buildContainerCircle(8),
                          buildContainerCircle(9),
                          buildRemoveIcon(Icons.close),
                          buildContainerCircle(0),
                          buildContainerIcon(Icons.arrow_back),
                        ],
                      ),
                    ),
                  ),
                  if (widget.buttonChild != null)
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 56,
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      child: OutlineButton(
                        onPressed: (!widget.verifyButtonEnabled || _currentCodeLength < widget.passLength)
                            ? null
                            : () => _verifyPassCode(),
                        child: widget.buttonChild,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
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

  Widget buildContainerCircle(int number) {
    return InkResponse(
      highlightColor: Colors.red,
      onTap: () {
        _onCodeClick(number);
      },
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: new Border.all(color: widget.numBorderColor, width: .8),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 0,
              )
            ]),
        child: Center(
          child: Text(
            number.toString(),
            style: TextStyle(
                fontSize: 28, fontFamily: widget.numFontFamily, fontWeight: FontWeight.normal, color: widget.numColor),
          ),
        ),
      ),
    );
  }

  Widget buildRemoveIcon(IconData icon) {
    return InkResponse(
      onTap: () {
        if (0 < _currentCodeLength) {
          _deleteAllCode();
        }
      },
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: new Border.all(color: widget.numBorderColor, width: .8),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 0,
              )
            ]),
        child: Center(
          child: Icon(
            icon,
            size: 30,
            color: widget.numColor,
          ),
        ),
      ),
    );
  }

  Widget buildContainerIcon(IconData icon) {
    return InkResponse(
      onTap: () {
        if (0 < _currentCodeLength) {
          setState(() {
            circleColor = Colors.grey.shade300;
          });
          Future.delayed(Duration(milliseconds: 200)).then((func) {
            setState(() {
              circleColor = Colors.white;
            });
          });
        }
        _deleteCode();
      },
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: new Border.all(color: widget.numBorderColor, width: .8),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 0,
              )
            ]),
        child: Center(
          child: Icon(
            icon,
            size: 30,
            color: widget.numColor,
          ),
        ),
      ),
    );
  }
}

class CodePanel extends StatelessWidget {
  final codeLength;
  final currentLength;
  final borderColor;
  final bool fingerVerify;
  final foregroundColor;
  final H = 30.0;
  final W = 30.0;
  final DeleteCode deleteCode;
  final int status;
  CodePanel(
      {this.codeLength,
      this.currentLength,
      this.borderColor,
      this.foregroundColor,
      this.deleteCode,
      this.fingerVerify,
      this.status})
      : assert(codeLength > 0),
        assert(currentLength >= 0),
        assert(currentLength <= codeLength),
        assert(deleteCode != null),
        assert(status == 0 || status == 1 || status == 2);

  @override
  Widget build(BuildContext context) {
    var circles = <Widget>[];
    var color = borderColor;
    int circlePice = 1;

    if (fingerVerify == true) {
      do {
        circles.add(
          SizedBox(
            width: W,
            height: H,
            child: new Container(
              height: H,
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                border: new Border.all(color: color, width: 0.8),
                color: Colors.green.shade500,
              ),
            ),
          ),
        );
        circlePice++;
      } while (circlePice <= codeLength);
    } else {
      if (status == 1) {
        color = Colors.green.shade500;
      }
      if (status == 2) {
        color = Colors.red.shade500;
      }
      for (int i = 1; i <= codeLength; i++) {
        if (i > currentLength) {
          circles.add(SizedBox(
              width: W,
              height: H,
              child: Container(
                height: H,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  border: new Border.all(color: color, width: 0.8),
                  color: foregroundColor,
                ),
              )));
        } else {
          circles.add(
            new SizedBox(
              width: W,
              height: H,
              child: new Container(
                height: H,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  border: new Border.all(color: color, width: 0.8),
                  color: color,
                ),
              ),
            ),
          );
        }
      }
    }

    return new SizedBox.fromSize(
      size: new Size(MediaQuery.of(context).size.width, H),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox.fromSize(
            size: new Size(40.0 * codeLength, H),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: circles,
            ),
          ),
        ],
      ),
    );
  }
}

class BgClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height / 1.5);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
