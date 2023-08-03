import 'package:flutter/material.dart';
import 'package:bookspark/presentation/modules/clubs/services/firebase_club_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/controllers/bloc/app_bloc.dart';

class JoinClubPage extends StatefulWidget {
  final Function updateClubsView;
  const JoinClubPage({Key? key, required this.updateClubsView}) : super(key: key);

  @override
  _JoinClubPageState createState() => _JoinClubPageState();
}

class _JoinClubPageState extends State<JoinClubPage> {
  List<dynamic> _clubs = [];
  List<dynamic> _searchResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClubs();
  }

  void _loadClubs() async {
    final clubs = await getClubs();
    setState(() {
      _clubs = clubs;
      _isLoading = false;
    });
  }

  void _searchClubs(String query) {
    setState(() {
      _searchResults = _clubs.where((club) => club['name'].toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

void _joinClub(dynamic club,String userId) {
  final clubId = club['clubID'];
  final userUId = userId;

  joinClub(clubId, userUId).then((_) {
    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Te has unido al club ${club['name']}')),
    );
    widget.updateClubsView();
    Navigator.pop(context);
  }).catchError((error) {
    // Show an error message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error al unirse al club')),
    );
  });
}


  @override
  Widget build(BuildContext context) {

    final user = context.select((AppBloc bloc) => bloc.state.user);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar y unirse a un club'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar club',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _searchClubs(value);
              },
            ),
          ),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.isNotEmpty ? _searchResults.length : _clubs.length,
                    itemBuilder: (context, index) {
                      final club = _searchResults.isNotEmpty ? _searchResults[index] : _clubs[index];
                      return ListTile(
                        title: Text(club['name']),
                        subtitle: Text(club['description']),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                        onTap: () {
                          _joinClub(club,user.id);
                        },
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
