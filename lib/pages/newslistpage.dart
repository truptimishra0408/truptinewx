import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:truptiboppo/helpers/DbHelper.dart';
import 'package:truptiboppo/helpers/Urls.dart';
import 'package:truptiboppo/models/News.dart';
import 'package:http/http.dart' as http;
import 'package:truptiboppo/pages/webviewcontainer.dart';

Future<List<News>> fetchNewsFromDatabase() async {
  var dbHelper = DBHelper();
  Future<List<News>> news = dbHelper.getNews();
  return news;
}

Future<int> fetchNewsTodayCount()  async {
  var dbHelper = DBHelper();
  int newscnt = await dbHelper.getNewsCount();
  return newscnt;
}

void saveNews(News news) async {
  var dbHelper = DBHelper();
  dbHelper.saveNews(news);
}


class NewsListPage extends StatefulWidget {
  const NewsListPage({Key? key}) : super(key: key);

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {


  Widget listTileItem(String author,String title,String url,String urlimage,String publishedat){


    saveNews(new News(author:(author==null?'':author),title: title,url:url,urlimage: urlimage,publishedat: publishedat));



    return GestureDetector(
        onTap: (){
          //  final snackBar = SnackBar(content: Text('Yay! A SnackBar!'));

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.
          //ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => WebViewContainer(url)));

        },
        child:Card(
          elevation: 2,

          child: Container(

            padding: EdgeInsets.only(left: 10,top: 10, bottom: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10)
            ),
            width: double.infinity,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children:[
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height/4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20))
                      ),

                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: Image(image:NetworkImage(urlimage),fit: BoxFit.contain, width: 120, height: 80,),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)),

                          ),
                         ),
                        ),
                      flex: 2,
                    ),

                  Expanded(child: SizedBox(
                    width: 1,
                  )),

                  Expanded(
                    flex: 5,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(title,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18.0)),
                          SizedBox(height: 5,),
                          Text(author,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12.0)),
                          Divider()
                        ]),
                  ),]
            )


          ),
        )
    );
  }


  Future<List<dynamic>> _fetchNews() async {

    // final jobsListAPIUrl = 'https://mock-json-service.glitch.me/';
    //dynamic token=SharedPreferencesHelper.getToken();
    //print(token.toString());
    //ChatApi.getAllChats(SharedPreferencesHelper.getToken());
    //String token= "johncena@gmail.com";

    //print("Token value is as follows $token");
    final response = await http.get(
      Uri.parse(Urls.baseUrl),
    );

    if (response.statusCode == 200) {
      print (response.body);
      //List jsonResponse = json.decode(response.body);
      Map<String, dynamic> map = json.decode(response.body);
      //print ("JSON RESPONSE $jsonResponse");
      List<dynamic> data = map["articles"];
      //   print(data[0]["name"]);
      //List<dynamic> data = map["groups"];

      // print(data[0]["name"]);
      //  return jsonResponse.map((grps) => new Group.fromJson(grps)).toList();


      return data;
    } else {
      print(response.statusCode);
      throw Exception('Failed to load notifications from API');
    }
  }


  ListView _newsListView(data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          // print(data[index].profile_pic);
          //String author,String title,String url,String urlimage,String publishedat
          return listTileItem((data[index]["author"]!=null? data[index]["author"]:''),data[index]["title"], data[index]["url"], data[index]["urlToImage"], data[index]["publishedAt"] );
          // listTileItem(String assetpath,String usrname,String usrlstmsg)
        });
  }


  ListView _newsListViewCache(data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          // print(data[index].profile_pic);
          //String author,String title,String url,String urlimage,String publishedat
          return listTileItem(data["author"],data[index]["title"], data[index]["url"], data[index]["urlToImage"], data[index]["publishedAt"] );
          // listTileItem(String assetpath,String usrname,String usrlstmsg)
        });
  }




  int newslog=0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchNewsTodayCount().then((value) => {
      newslog=value
    });

  }




  @override
  Widget build(BuildContext context) {

    if(newslog==0) {
      print("Running Fresh");
      return Scaffold(
        appBar: AppBar(
          title: Image(
            image: AssetImage("assets/newslogo.png"), height: 120, width: 80,),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(

              child: Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                margin: EdgeInsets.only(top: 30),
                child: Column(
                  children: <Widget>[

                    Expanded(
                      child: FutureBuilder<List<dynamic>>(
                        future: _fetchNews(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<dynamic>? data = snapshot.data;

                            return _newsListView(data);
                          } else if (snapshot.hasError) {
                            //return Text("${snapshot.error}");
                            return Text("No News Subscribed yet");
                          }
                          return CircularProgressIndicator();
                        },
                      ),
                    )
                  ],
                ),
              )
          ),
        ),
      );
    }
    else {
      print("Running from cache storage");
      return new Scaffold(
        appBar: AppBar(
          title: Image(
            image: AssetImage("assets/newslogo.png"), height: 120, width: 80,),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: new Container(
          padding: new EdgeInsets.all(16.0),
          child: new FutureBuilder<List<News>>(
            future: fetchNewsFromDatabase(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return new ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      // return new Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: <Widget>[
                      //       new Text(snapshot.data![index].title,
                      //           style: new TextStyle(
                      //               fontWeight: FontWeight.bold, fontSize: 18.0)),
                      //       new Text(snapshot.data![index].author,
                      //           style: new TextStyle(
                      //               fontWeight: FontWeight.bold, fontSize: 14.0)),
                      //       new Divider()
                      //     ]);



                      return GestureDetector(
                          onTap: (){
                            //  final snackBar = SnackBar(content: Text('Yay! A SnackBar!'));

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.
                            //ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => WebViewContainer(snapshot.data![index].url)));

                          },
                          child:Card(
                            elevation: 2,

                            child: Container(

                                padding: EdgeInsets.only(left: 10,top: 10, bottom: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                width: double.infinity,
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children:[
                                      Expanded(
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context).size.height/4,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(20))
                                          ),

                                          child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            height: MediaQuery.of(context).size.height,
                                            child: Image(image:NetworkImage(snapshot.data![index].urlimage),fit: BoxFit.contain, width: 120, height: 80,),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(20)),

                                            ),
                                          ),
                                        ),
                                        flex: 2,
                                      ),

                                      Expanded(child: SizedBox(
                                        width: 1,
                                      )),

                                      Expanded(
                                        flex: 5,
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(snapshot.data![index].title,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold, fontSize: 18.0)),
                                              SizedBox(height: 5,),
                                              Text(snapshot.data![index].author,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold, fontSize: 12.0)),
                                              Divider()
                                            ]),
                                      ),]
                                )


                            ),
                          )
                      );



                    });
              } else if (snapshot.hasError) {
                return new Text("${snapshot.error}");
              }
              return new Container(alignment: AlignmentDirectional.center,child: new CircularProgressIndicator(),);
            },
          ),
        ),
      );
    }
  }
}
