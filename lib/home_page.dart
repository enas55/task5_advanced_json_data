import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // bool isLoading = false;
  // String errorMessage = '';
  // List<Person> persons = [];

  var isLoadingNotifier = ValueNotifier(false);
  var errorMessageNotifier = ValueNotifier('');
  var personsNotifier = ValueNotifier<List<Person>>([]);

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    // isLoading = true;
    // setState(() {});

    isLoadingNotifier.value = true;

    var result = await rootBundle.loadString('assets/data.json');
    var response = jsonDecode(result);
    if (response['sucess']) {
      personsNotifier.value = List<Person>.from(
          response['data'].map((e) => Person.fromJson(e)).toList());
    } else {
      errorMessageNotifier.value =
          'Error : ${response['statusCode'] ?? ' unknown error'}';
    }
    // isLoading = false;
    // setState(() {});
    isLoadingNotifier.value = false;
  }

  @override
  void dispose() {
    isLoadingNotifier.dispose();
    errorMessageNotifier.dispose();
    personsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Persons List'),
      ),
      body: ValueListenableBuilder(
          valueListenable: isLoadingNotifier,
          builder: (context, isLoading, _) {
            return isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ValueListenableBuilder(
                    valueListenable: errorMessageNotifier,
                    builder: (context, errorMsg, _) {
                      return errorMsg.isNotEmpty
                          ? const Center(
                              child: Text('Error 400'),
                            )
                          : ValueListenableBuilder(
                              valueListenable: personsNotifier,
                              builder: (context, persons, _) {
                                return ListView(
                                  children: persons
                                      .map((e) => ListTile(
                                            title: Text(e.name),
                                            trailing: Text(e.phone),
                                            subtitle: Text(e.address.city),
                                          ))
                                      .toList(),
                                );
                              });
                    });
          }),
    );
  }
}

class Person {
  late int id;
  late String name;
  late String email;
  late int age;
  late String phone;
  late Address address;

  Person.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    name = data['name'];
    email = data['email'];
    age = data['age'];
    phone = data['phone'];
    address = Address.fromJson(data['address']);
  }
}

class Address {
  late String street;
  late String city;
  late String state;

  Address.fromJson(Map<String, dynamic> address) {
    street = address['street'];
    city = address['city'];
    state = address['state'];
  }
}
