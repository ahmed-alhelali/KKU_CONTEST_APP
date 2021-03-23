import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kku_contest_app/localization/my_localization.dart';
import 'package:kku_contest_app/models/app_theme.dart';
import 'package:kku_contest_app/screens/wrapper_screen.dart';
import 'package:kku_contest_app/utils/utils.dart';
import 'package:kku_contest_app/widgets/widgets.dart';

class InstructorDrawerScreen extends StatefulWidget {
  final AnimationController controller;

  const InstructorDrawerScreen({Key key, this.controller}) : super(key: key);

  @override
  _InstructorDrawerScreenState createState() => _InstructorDrawerScreenState();
}

class _InstructorDrawerScreenState extends State<InstructorDrawerScreen> {
  Animation<double> _scaleAnimation;
  Animation<Offset> _slideAnimation;

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);

    if (_scaleAnimation == null) {
      _scaleAnimation =
          Tween<double>(begin: 0.6, end: 1).animate(widget.controller);
    }
    if (_slideAnimation == null) {
      _slideAnimation = textDirection == TextDirection.ltr
          ? Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
              .animate(widget.controller)
          : Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
              .animate(widget.controller);
    }
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        alignment: Alignment.topRight,
        child: Container(
          color: AppTheme.darkTheme.backgroundColor,
          child: ListView(
            children: [
              SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional.topStart,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.darkTheme.scaffoldBackgroundColor,
                    borderRadius: textDirection == TextDirection.ltr
                        ? BorderRadius.only(
                            topRight: Radius.circular(25),
                            bottomRight: Radius.circular(25),
                          )
                        : BorderRadius.only(
                            topLeft: Radius.circular(25),
                            bottomLeft: Radius.circular(25),
                          ),
                  ),
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Center(
                    child: Text(
                      MyLocalization.of(context)
                          .getTranslatedValue("instructor")
                          .toUpperCase(),
                      style: textDirection == TextDirection.ltr
                          ? Utils.getUbuntuTextStyleWithSize(18)
                          : Utils.getTajwalTextStyleWithSize(18),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 30,
                  ),
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundImage:
                            ExactAssetImage("assets/images/instructor.png"),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        MyLocalization.of(context)
                            .getTranslatedValue("instructor_name"),
                        style: textDirection == TextDirection.ltr
                            ? Utils.getUbuntuTextStyleWithSize(16)
                            : Utils.getTajwalTextStyleWithSize(14),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 40),
              Widgets.getContainerWithOnOnTap(
                Icon(
                  Icons.menu_book,
                  color: Colors.white,
                ),
                "my_courses",
                textDirection,
                context,
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.25,
                width: MediaQuery.of(context).size.width * 0.5,
                //color: Colors.grey,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: getInstructorCourses(textDirection),
              ),
              Widgets.getContainerWithOnOnTap(
                Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                "logout",
                textDirection,
                context,
                onTap: () {
                  Widgets.showWarringDialog(
                      "are_you_sure",
                      "instructor_logout_warning",
                      context,
                      "logout",
                      "cancel", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WrapperScreen(),
                      ),
                    );
                  }, () {
                    Navigator.of(context).pop();
                  }, textDirection);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getInstructorCourses(TextDirection textDirection) {
    CollectionReference courses =
        FirebaseFirestore.instance.collection("Courses");

    return StreamBuilder<QuerySnapshot>(
      stream: courses.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  MyLocalization.of(context)
                      .getTranslatedValue("error_connection"),
                  style: textDirection == TextDirection.ltr
                      ? Utils.getUbuntuTextStyleWithSize(14)
                      : Utils.getTajwalTextStyleWithSize(14),
                )
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
              ],
            ),
          );
        }

        if (snapshot.data.size == 0) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  MyLocalization.of(context).getTranslatedValue("no_courses"),
                  style: textDirection == TextDirection.ltr
                      ? Utils.getUbuntuTextStyleWithSize(14)
                      : Utils.getTajwalTextStyleWithSize(14),
                )
              ],
            ),
          );
        }

        return ListView(
          padding: textDirection == TextDirection.ltr
              ? EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.5)
              : EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.5),
          children: snapshot.data.docs.map(
            (DocumentSnapshot document) {
              final currentCourse = document.data().values;
              // print(currentCourse);
              return Column(
                children: [
                  ListTile(
                    title: Text(
                      currentCourse.first,
                      style: textDirection == TextDirection.ltr
                          ? Utils.getUbuntuTextStyleWithSize(12)
                          : Utils.getTajwalTextStyleWithSize(12),
                    ),
                  ),
                  SizedBox(
                    height: 0.5,
                    child: Container(color: Colors.grey),
                  ),
                ],
              );
            },
          ).toList(),
        );
      },
    );
  }
}
