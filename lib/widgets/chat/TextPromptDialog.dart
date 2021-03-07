import 'package:flutter/material.dart';

class TextPromptDialog<T> extends StatefulWidget {
  final Widget title;
  final Widget callToAction;
  final String hintText;
  final Future<T> Function(String) action;

  TextPromptDialog({
    @required this.title,
    @required this.callToAction,
    @required this.action,
    this.hintText,
  });

  @override
  _TextPromptDialogState<T> createState() => _TextPromptDialogState<T>();
}

class _TextPromptDialogState<T> extends State<TextPromptDialog<T>> {
  final TextEditingController _textEditingController = TextEditingController();
  bool _isLoading = false;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title,
      titlePadding: EdgeInsets.only(top: 16, left: 16, right: 16),
      contentPadding: EdgeInsets.all(16),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(6.0),
                  ),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                hintText: widget.hintText ?? "",
              ),
              autofocus: true,
              controller: _textEditingController,
            ),
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
                  textColor: Theme.of(context).accentColor,
                  color: Theme.of(context).errorColor,
                  child: Text('NEVERMIND'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Padding(padding: EdgeInsets.only(left: 8)),
              Expanded(
                child: RaisedButton(
                  color: Theme.of(context).accentColor,
                  child: _isLoading
                      ? Container(
                          constraints:
                              BoxConstraints(maxHeight: 20, maxWidth: 20),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor),
                          ))
                      : widget.callToAction,
                  onPressed: () async {
                    if (_isLoading) return;
                    try {
                      setState(() {
                        _isLoading = true;
                      });
                      T item = await widget.action(_textEditingController.text);
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
