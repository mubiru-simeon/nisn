import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:nisn/constants/ui.dart';
import 'package:nisn/models/thing_type.dart';
import 'package:nisn/services/communications.dart';
import 'package:nisn/services/ui_services.dart';
import 'package:nisn/views/no_data_found_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/basic.dart';
import '../models/user.dart';
import '../widgets/edit_user_permissions_bottom_sheet.dart';
import '../widgets/loading_widget.dart';
import '../widgets/paginate_firestore/paginate_firestore.dart';
import '../widgets/selector.dart';
import '../widgets/single_big_button.dart';
import '../widgets/single_search_result.dart';
import '../widgets/single_user.dart';
import '../widgets/top_back_bar.dart';
import 'not_yet_searching.dart';

class AllUsersView extends StatefulWidget {
  final bool returning;
  final String mode;
  AllUsersView({
    Key key,
    this.returning = false,
    this.mode,
  }) : super(key: key);

  @override
  State<AllUsersView> createState() => _AllUsersViewState();
}

class _AllUsersViewState extends State<AllUsersView> {
  String selectedUser;
  List<AlgoliaObjectSnapshot> _results = [];
  TextEditingController _nameController = TextEditingController();
  Timer searchOnStoppedTyping;
  bool searching = false;
  bool onSearchView = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        mainView(),
        if (onSearchView) searchPage(),
      ],
    );
  }

  _onChangeHandler(value) {
    const duration = Duration(
      milliseconds: 200,
    );
    if (searchOnStoppedTyping != null) {
      searchOnStoppedTyping.cancel(); // clear timer
    }

    searchOnStoppedTyping = Timer(
      duration,
      () => doIt(value),
    );
  }

  doIt(String vg) {
    _search(
      vg,
      allIndex,
    );
  }

  _search(String searchText, String indexToQuery) {
    Future.delayed(Duration(milliseconds: 100), () async {
      if (searchText.trim().isNotEmpty) {
        if (mounted) {
          setState(() {
            searching = true;
          });
        }

        if (mounted) {
          setState(() {
            searching = true;
          });
        }

        Algolia algolia = Algolia.init(
          applicationId: algoliaAppID,
          apiKey: searchApiKey,
        );

        AlgoliaQuery query =
            algolia.instance.index(indexToQuery).query(searchText.trim());

        _results = (await query.getObjects()).hits;

        if (mounted) {
          setState(() {
            searching = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _results.clear();
          });
        }
      }
    });
  }

  Widget searchPage() {
    List pp = [];

    for (var element in _results) {
      if (element.data["type"] == ThingType.USER) {
        pp.add(element);
      }
    }

    return Scaffold(
      floatingActionButton: widget.returning
          ? FloatingActionButton(
              onPressed: () {
                finish();
              },
              child: Icon(
                Icons.done,
              ),
            )
          : null,
      appBar: AppBar(
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Text(
                "Go",
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 16,
                ),
              ),
            ),
          )
        ],
        backgroundColor: Theme.of(context).canvasColor,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.grey,
              ),
              onTap: () {
                setState(() {
                  onSearchView = false;
                });
              },
            ),
            Expanded(
              child: TextField(
                autofocus: true,
                onTap: () {},
                controller: _nameController,
                onChanged: (v) {
                  _onChangeHandler(v);
                },
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 15,
                      color: primaryColor,
                    ),
                    onPressed: () {
                      _nameController.clear();
                      if (mounted) {
                        setState(() {
                          _results.clear();
                          searching = false;
                        });
                      }
                    },
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                  ),
                  hintText: "Search",
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        child: searching
            ? LoadingWidget()
            : _nameController.text.trim().isEmpty
                ? NotYetSearchingView(
                    text: "What exactly are you looking for?",
                  )
                : pp.isEmpty
                    ? NoDataFound(text: "No Results")
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                        itemCount: pp.length,
                        itemBuilder: (context, index) {
                          return SingleSearchResult(
                            list: false,
                            sensitive: true,
                            allowedTypes: [ThingType.USER],
                            thing: pp[index].data,
                            horizontal: false,
                            fullWidth: null,
                            searchedText: _nameController.text.trim(),
                            selectable: widget.returning,
                            selected:
                                selectedUser == pp[index].data["objectID"],
                            onTap: () {
                              if (widget.returning) {
                                setState(() {
                                  selectedUser = pp[index].data["objectID"];
                                });
                              } else {}
                            },
                            type: pp[index].data["type"],
                          );
                        },
                      ),
      ),
    );
  }

  Widget mainView() {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BackBar(
              icon: null,
             
              onPressed: null,
              text: "All Users",
            ),
            Expanded(
              child: PaginateFirestore(
                header: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              onSearchView = true;
                            });
                          },
                          child: Material(
                            borderRadius: standardBorderRadius,
                            elevation: standardElevation,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Row(
                                  children: [
                                    Text(
                                      "Search.....",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.search,
                                      color: Colors.black,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                isLive: true,
                onEmpty: NoDataFound(
                  text: "No Users Yet. Tap the add button to add",
                ),
                itemsPerPage: 4,
                itemBuilder: (
                  context,
                  snapshot,
                  index,
                ) {
                  UserModel userModel = UserModel.fromSnapshot(snapshot[index]);

                  return Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: standardBorderRadius,
                        ),
                        child: Column(
                          children: [
                            SingleUser(
                              user: userModel,
                              onTap: () {
                                if (widget.returning) {
                                  setState(() {
                                    selectedUser = userModel.id;
                                  });
                                } else {}
                              },
                              userID: userModel.id,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: SingleBigButton(
                                    color: primaryColor,
                                    onPressed: () {
                                      UIServices().showDatSheet(
                                        EditUserPermissionsBottomSheet(
                                          user: userModel,
                                        ),
                                        true,
                                        context,
                                      );
                                    },
                                    text: "Edit Permissions",
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      if (selectedUser == userModel.id) SelectorThingie(),
                    ],
                  );
                },
                query: widget.mode == null
                    ? FirebaseFirestore.instance.collection(UserModel.DIRECTORY)
                    : FirebaseFirestore.instance
                        .collection(UserModel.DIRECTORY)
                        .where(
                          widget.mode,
                          isEqualTo: true,
                        ),
                itemBuilderType: PaginateBuilderType.listView,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: widget.returning
          ? FloatingActionButton(
              onPressed: () {
                finish();
              },
              child: Icon(
                Icons.done,
              ),
            )
          : null,
    );
  }

  finish() {
    if (selectedUser == null) {
      CommunicationServices().showToast(
        "Please select a user",
        Colors.red,
      );
    } else {
      Navigator.of(context).pop(selectedUser);
    }
  }
}
