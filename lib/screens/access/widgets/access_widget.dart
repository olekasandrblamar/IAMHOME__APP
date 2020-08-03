import 'package:flutter/material.dart';
import 'package:ceras/models/access_model.dart';
import 'package:ceras/theme.dart';

class AccessWidget extends StatelessWidget {
  const AccessWidget({
    Key key,
    @required this.accessData,
    @required this.onNothingSelected,
    @required this.onPermissionSelected,
  }) : super(key: key);

  final AccessModel accessData;
  final VoidCallback onPermissionSelected;
  final VoidCallback onNothingSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              constraints: BoxConstraints(
                maxHeight: 300.0,
              ),
              padding: const EdgeInsets.all(10.0),
              child: FadeInImage(
                placeholder: AssetImage(
                  'assets/images/placeholder.jpg',
                ),
                image: AssetImage(
                  accessData.image,
                ),
                fit: BoxFit.contain,
                alignment: Alignment.center,
                fadeInDuration: Duration(milliseconds: 200),
                fadeInCurve: Curves.easeIn,
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                accessData.title,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTheme.title,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                // vertical: 5.0,
                horizontal: 35.0,
              ),
              child: Text(
                accessData.description,
                textAlign: TextAlign.center,
                style: AppTheme.subtitle,
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 150,
                  height: 75,
                  padding: EdgeInsets.all(10),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.5),
                    ),
                    color: Color(0XFFE6E6E6),
                    textColor: Colors.black,
                    child: Text(
                      'No, Thanks',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    onPressed: () => onNothingSelected(),
                  ),
                ),
                Container(
                  width: 150,
                  height: 75,
                  padding: EdgeInsets.all(10),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.5),
                    ),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text(
                      'I\'m In',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    onPressed: () => onPermissionSelected(),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
