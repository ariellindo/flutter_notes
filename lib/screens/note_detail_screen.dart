import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_notes/blocs/blocs.dart';
import 'package:flutter_notes/models/models.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;

  NoteDetailScreen({Key key, this.note}) : super(key: key);

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  bool get _isEditing => widget.note != null;
  final FocusNode _contentFocusNode = FocusNode();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _contentController.text = widget.note.content;
    } else {
      SchedulerBinding.instance.addPostFrameCallback(
          (_) => FocusScope.of(context).requestFocus(_contentFocusNode));
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (_isEditing) {
          context.bloc<NoteDetailsBloc>().add(NoteSaved());
        }
        return Future.value(true);
      },
      child: BlocConsumer<NoteDetailsBloc, NoteDetailState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              actions: <Widget>[_buildAction()],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                bottom: 80.0,
                top: 40.0,
              ),
              child: TextField(
                focusNode: _contentFocusNode,
                style: const TextStyle(
                  fontSize: 18.0,
                  height: 1.2,
                ),
                decoration: const InputDecoration.collapsed(
                  hintText: 'Write about anything :)',
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) => context
                    .bloc<NoteDetailsBloc>()
                    .add(NoteContentUpdated(content: value)),
              ),
            ),
          );
        },
        listener: (context, state) {
          if (state.isSuccess) {
            Navigator.of(context).pop();
          } else if (state.isFailure) {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Error'),
                    content: Text(state.errorMessage),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("OK"),
                      ),
                    ],
                  );
                });
          }
        },
      ),
    );
  }

  FlatButton _buildAction() {
    return _isEditing
        ? FlatButton(
            onPressed: () => context.bloc<NoteDetailsBloc>().add(NoteDeleted()),
            child: Text(
              'Delete',
              style: const TextStyle(
                fontSize: 17.0,
                color: Colors.red,
              ),
            ),
          )
        : FlatButton(
            onPressed: () => context.bloc<NoteDetailsBloc>().add(NoteAdded()),
            child: Text(
              'Add Note',
              style: TextStyle(
                fontSize: 17.0,
                color: Colors.amber,
              ),
            ),
          );
  }
}
