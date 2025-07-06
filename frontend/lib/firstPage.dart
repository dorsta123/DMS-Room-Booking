import 'package:flutter/material.dart';
import 'package:frontend/room.dart';

class Firstpage extends StatefulWidget {
  const Firstpage ({super.key});
  @override
State <Firstpage> createState()=>_FirstpageState();

}
class _FirstpageState extends  State <Firstpage>{

  final List <Map <String, dynamic>> professor= [
    {
      'name':'Saurav Jain',
      'desc': 'I am the Assistant Professor of Computer Programming',
        'color': Colors.yellow,
        'colorName': 'yellow',

    },
      {
    'name': 'Vinay Pathak',
    'desc': 'I am the Assistant Professor of Data Structure & Algorithms',
    'color': Colors.red,
    'colorName': 'red'
  },
  {
    'name': 'M.D Gupta',
    'desc': 'I am the Assistant Professor of Business Studies',
    'color': Colors.blue,
    'colorName': 'blue'
  },
  {
    'name': 'Zamir Ahmed Ansari',
    'desc': 'I am the Assistant Professor of Engineering Mathematics',
    'color': Colors.green,
    'colorName': 'green',
  },
  {
    'name': 'Arquam',
    'desc': 'I am the Assistant Professor of Computer Networking',
    'color': Color.fromARGB(255, 146, 102, 86),
    'colorName':'brown',
  },
  ];
  @override
  Widget build(BuildContext context) {

    return Scaffold(
body: Center(
  child:SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    physics: BouncingScrollPhysics(),
    child: Row(
      children: professor.map((prof) {
      return  SizedBox(
          height:400,
          width:350,
          child: Card(
            margin: EdgeInsets.all(16),
            color:prof['color'],
            elevation: 10,
            child:Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                        'Dr. ${prof['name']}',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    Spacer(flex: 1),
                    Text(prof['desc'],
                     style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),),
                      Spacer(flex: 1),  
                    ElevatedButton(onPressed:(){
                      Navigator.push(context, MaterialPageRoute(builder: (context)
                      {return Room(
                      profName: prof['name'],
                      profColor: prof['colorName']  
                      );
                      },));
                    }, 
                    child: Text('Click here',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    )
                    ),         
                  ],
                ),
              ),
            )
          ),
        );
      }).toList(),
      
    ),
  
  ),
      
)
    );
  }
}