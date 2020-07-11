import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_notes/blocs/auth/auth_bloc.dart';
import 'package:flutter_notes/blocs/blocs.dart';
import 'package:flutter_notes/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        context.bloc<NotesBloc>().add(FetchNotes());
      },
      builder: (context, authState) {
        return Scaffold(
          body: BlocBuilder<NotesBloc, NotesState>(
            builder: (context, notesState) {
              return _buildBody(context, authState, notesState);
            },
          ),
        );
      },
    );
  }

  Stack _buildBody(
    BuildContext context,
    AuthState authState,
    NotesState notesState,
  ) {
    return Stack(
      children: <Widget>[
        CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              floating: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('Your Notes'),
              ),
              leading: IconButton(
                icon: AuthState is Authenticated
                    ? Icon(Icons.exit_to_app)
                    : Icon(Icons.account_circle),
                onPressed: () => {
                  authState is Authenticated
                      ? context.bloc<AuthBloc>().add(Logout())
                      : print('Go to Login'),
                },
                iconSize: 28.0,
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.brightness_4),
                  onPressed: () => print("change theme"),
                ),
              ],
            ),
            notesState is NotesLoaded
                ? NotesGrid(
                    notes: notesState.notes, onTap: (note) => print(note))
                : const SliverPadding(padding: EdgeInsets.zero),
          ],
        ),
        notesState is NotesLoading
            ? Center(child: CircularProgressIndicator())
            : const SizedBox.shrink(),
        notesState is NotesError
            ? Center(
                child: Text(
                  "Something went wrong!\nPlease check your connection.",
                  textAlign: TextAlign.center,
                ),
              )
            : const SizedBox.shrink()
      ],
    );
  }
}
