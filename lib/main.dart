import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //device orientation is set to portrait only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Library',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          headline6: TextStyle(
              fontSize: 40.0,
              color: Colors.white,
              fontWeight: FontWeight.w300,
              fontFamily: 'BristleBrush'),
          headline5: TextStyle(
              fontSize: 25.0,
              color: Colors.white,
              fontWeight: FontWeight.w300,
              fontFamily: 'CaviarDreams'),
          headline4: TextStyle(
              fontSize: 15.0,
              color: Colors.black,
              fontWeight: FontWeight.w300,
              fontFamily: 'CaviarDreams'),
          headline3: TextStyle(
              fontSize: 30.0,
              color: Colors.white,
              fontFamily: 'LouisGeorgeCafe_Bold'),
          headline2: TextStyle(
              fontSize: 16.0,
              color: Colors.white70,
              fontFamily: 'LouisGeorgeCafe'),
          headline1: TextStyle(
              fontSize: 20.0,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontFamily: 'LouisGeorgeCafe'),
          subtitle1: TextStyle(
              fontSize: 18.0,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              fontFamily: 'LouisGeorgeCafe'),
          subtitle2: TextStyle(
              fontSize: 18.0,
              color: Colors.black45,
              fontWeight: FontWeight.w400,
              fontFamily: 'LouisGeorgeCafe'),
        ),
        appBarTheme: AppBarTheme(
          color: Colors.black,
        ),
        iconTheme: IconThemeData(color: Colors.white, size: 28),
      ),
      home: SearchPage(title: 'My Library'),
    );
  }
}

class SearchPage extends StatefulWidget {
  SearchPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title, style: Theme.of(context).textTheme.headline6),
      ),
      body: Stack(children: <Widget>[
        Container(
          decoration: backgroundImage(),
        ),
        Container(
          decoration: backgroundGradient(),
        ),
        Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                SizedBox(height: 15),
                BookList(),
              ],
            ),
          ],
        ),
      ]),
    );
  }
}

class BookList extends StatefulWidget {
  BookList({Key key}) : super(key: key);

  @override
  _BookListState createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  final TextEditingController bookController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    bookController.addListener(_printLatestValue);
  }

  @override
  void dispose() {
    bookController.dispose();
    super.dispose();
  }

  _printLatestValue() {
    print("Text field: ${bookController.text}");
  }

  String search = "";

  //fetch data from api
  Future<List<Book>> _getBooks() async {
    var googleAPI = "";

    //default search
    if (search == "") {
      googleAPI = "https://www.googleapis.com/books/v1/volumes?q=IT";
    } else {
      googleAPI = "https://www.googleapis.com/books/v1/volumes?q=";
    }
    search = search.replaceAll(' ', '+');
    var data = await http.get(googleAPI + search);
    print(googleAPI + search);

    //convert response to json Object
    var jsonData = json.decode(data.body);

    //Store data in Book list from JsonData
    List<Book> books = [];
    for (var item in jsonData["items"]) {
      //handles null variables
      if (item["volumeInfo"]["authors"][0] == null) {
        item["volumeInfo"]["authors"][0] = "";
        print("author null");
      }
      if (item["volumeInfo"]["title"] == null) {
        item["volumeInfo"]["title"] = "";
        print("title null");
      }
      if (item["volumeInfo"]["publisher"] == null) {
        item["volumeInfo"]["publisher"] = "";
        print("publisher null");
      }
      if (item["volumeInfo"]["publishedDate"] == null) {
        item["volumeInfo"]["publishedDate"] = "";
        print("publishedDate null");
      }
      if (item["volumeInfo"]["description"] == null) {
        item["volumeInfo"]["description"] = " No description";
        print("description null");
      }
      if (item["volumeInfo"]["imageLinks"]["thumbnail"] == null) {
        item["volumeInfo"]["imageLinks"]["thumbnail"] = "";
        print("thumbnail null");
      }

      Book book = new Book(
          item["volumeInfo"]["authors"][0],
          item["volumeInfo"]["title"],
          item["volumeInfo"]["publisher"],
          item["volumeInfo"]["publishedDate"],
          item["volumeInfo"]["description"],
          item["volumeInfo"]["imageLinks"]["thumbnail"]);

      //add data to book object
      books.add(book);
    }
    //return book list
    return books;
  }

  @override
  Widget build(BuildContext context) {
    //use future builder to get data from async function
    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    style: Theme.of(context).textTheme.headline5,
                    controller: bookController,
                    decoration: InputDecoration(
                      hintStyle: Theme.of(context).textTheme.headline5,
                      hintText: "Search Books",
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                    ),
                    cursorColor: Colors.white,
                    onChanged: (String text) {
                      setState(() {
                        search = text;
                        //startTimer();
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: _getBooks,
                ),
              ],
            ),
            Container(
              height: 10,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.brown)),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                  future: _getBooks(), // getBook function
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.data == null && snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        child: Center(
                          child: SizedBox(
                            child: CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.white)),
                            height: 100.0,
                            width: 100.0,
                          ),
                        ),
                      );
                    } else if (snapshot.data != null) {
                      return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            margin: EdgeInsets.fromLTRB(15, 13, 15, 0),
                            color: Colors.white.withOpacity(0.85),
                            elevation: 5,
                            child: InkWell(
                              onTap: () {
                                //navigate to book details page
                                Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                    builder: (context) =>
                                        BookDetails(snapshot.data[index]),
                                  ),
                                );
                              },
                              child: Row(
                                children: <Widget>[
                                  Image.network(
                                    snapshot.data[index].thumbnail,
                                    height: 115,
                                  ),
                                  Expanded(
                                    child: Column(children: <Widget>[
                                      Text(
                                        snapshot.data[index].title,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4,
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(snapshot.data[index].publisher,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center),
                                      Text(snapshot.data[index].publishedDate,
                                          textAlign: TextAlign.center),
                                    ]),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );

                    } else {
                      return Center(
                        child: Container(
                          height: 100.0,
                          width: 170.0,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Center(
                            child: Text(
                              "Search not found",
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ),
                        ),
                      );
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

// modal on tap to show book details
class BookDetails extends StatelessWidget {
  final Book book;

  BookDetails(this.book);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            Container(
              decoration: backgroundModalImage(),
            ),
            Container(
              decoration: backgroundModalGradient(),
            ),

            //book details
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 5,
                      ),
                      Image.network(book.thumbnail),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                book.title,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.headline3,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Authors: " + book.authors,
                                style: Theme.of(context).textTheme.headline2,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Publisher: " + book.publisher,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.headline2,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Publish Date: " + book.publishedDate,
                                style: Theme.of(context).textTheme.headline2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.white60),
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Description",
                                style: Theme.of(context).textTheme.headline1,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Title: " + book.title,
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Authors: " + book.authors,
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Publisher: " + book.publisher,
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                book.description,
                                style: Theme.of(context).textTheme.headline2,
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Book Class
class Book {
  final String authors;
  final String title;
  final String publisher;
  final String publishedDate;
  final String description;
  final String thumbnail;

//Constructor to intitilize
  Book(this.authors, this.title, this.publisher, this.publishedDate,
      this.description, this.thumbnail);
}

//search page background image
BoxDecoration backgroundImage() {
  return BoxDecoration(
    color: Colors.transparent,
    image: DecorationImage(
      image: AssetImage("assets/images/b5.jpg"),
      fit: BoxFit.fill,
    ),
  );
}

//search page background image
BoxDecoration backgroundGradient() {
  return BoxDecoration(
    color: Colors.white,
    gradient: LinearGradient(
      begin: FractionalOffset.bottomCenter,
      end: FractionalOffset.topCenter,
      colors: [
        Colors.black.withOpacity(0.2),
        Colors.black,
      ],
      stops: [0.0, 1.0],
    ),
  );
}

//modal background image
BoxDecoration backgroundModalImage() {
  return BoxDecoration(
    color: Colors.transparent,
    image: DecorationImage(
      image: AssetImage("assets/images/b2.jpg"),
      fit: BoxFit.fill,
    ),
  );
}

//modal gradient overlay
BoxDecoration backgroundModalGradient() {
  return BoxDecoration(
    color: Colors.white,
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black.withOpacity(0.8),
        Colors.brown.withOpacity(0.8),
      ],
      stops: [0.7, 1.0],
    ),
  );
}
