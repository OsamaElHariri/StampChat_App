import 'package:flutter/material.dart';

class ActionPromptDialog<T> extends StatefulWidget {
  final bool dangerousCallToAction;
  final Widget title;
  final Widget cancelAction;
  final Widget callToAction;
  final Widget actionPrompt;
  final Future<T> Function() action;

  ActionPromptDialog({
    @required this.title,
    @required this.callToAction,
    @required this.cancelAction,
    @required this.action,
    @required this.actionPrompt,
    this.dangerousCallToAction = false,
  });

  @override
  _ActionPromptDialogState<T> createState() => _ActionPromptDialogState<T>();
}

class _ActionPromptDialogState<T> extends State<ActionPromptDialog<T>> {
  bool _isLoading = false;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    Color rightBtnColor =
        widget.dangerousCallToAction ? theme.errorColor : theme.accentColor;
    Color rightBtnTextColor =
        widget.dangerousCallToAction ? theme.accentColor : theme.primaryColor;

    Color leftBtnColor =
        widget.dangerousCallToAction ? theme.accentColor : theme.errorColor;
    Color leftBtnTextColor =
        widget.dangerousCallToAction ? theme.primaryColor : theme.accentColor;

    return AlertDialog(
      title: widget.title,
      titlePadding: EdgeInsets.only(top: 16, left: 16, right: 16),
      contentPadding: EdgeInsets.all(16),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: widget.actionPrompt,
          ),
          Padding(padding: EdgeInsets.only(bottom: 4)),
          Visibility(
            visible: _hasError ? true : false,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: GestureDetector(
                onTap: () => setState(() => _hasError = false),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: Theme.of(context).errorColor,
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        size: 16,
                        color: Theme.of(context).accentColor,
                      ),
                      Padding(padding: EdgeInsets.only(left: 4)),
                      Text(
                        "Something went wrong",
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 4)),
          Row(
            children: <Widget>[
              Expanded(
                child: RaisedButton(
                  textColor: leftBtnTextColor,
                  color: leftBtnColor,
                  child: widget.cancelAction,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Padding(padding: EdgeInsets.only(left: 8)),
              Expanded(
                child: RaisedButton(
                  textColor: rightBtnTextColor,
                  color: rightBtnColor,
                  child: _isLoading
                      ? Container(
                          constraints:
                              BoxConstraints(maxHeight: 20, maxWidth: 20),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                rightBtnTextColor),
                          ))
                      : widget.callToAction,
                  onPressed: () async {
                    try {
                      if (_isLoading) return;
                      setState(() {
                        _isLoading = true;
                      });
                      T item = await widget.action();
                      Navigator.of(context).pop(item);
                    } catch (e) {
                      setState(() {
                        _isLoading = false;
                        _hasError = true;
                      });
                    }
                  },
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
