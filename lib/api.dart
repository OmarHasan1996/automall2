

import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;
import 'package:intl/intl.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:platform_device_id/platform_device_id.dart';

import 'color/MyColors.dart';
import 'const.dart';
import 'firebase/Firebase.dart';
import 'localization_service.dart';
import 'localizations.dart';
import 'package:mailer/mailer.dart';

import 'screen/singnIn.dart';
class MyAPI{
  final _baseUrl = 'https://automall-qa.com';
  //final _baseUrl = 'https://automallonline.info';

  Future register(name, phone, email, password, cityId, type) async{
    var fcmToken;
    try{
      fcmToken = await myFirebase.getToken();
      print(fcmToken);
      print(fcmToken);
    }
    catch(e){
      fcmToken='';
      print(e);
      flushBar(e.toString());
    }
    var  apiUrl =Uri.parse('$_baseUrl/SignUp/SignUp_Create');
    Map mapDate = {
      "Name": name,
      "LastName": 'last name',
      "Mobile": phone,
      "Email": email,
      "Password": password,
      "Type":type,
      "CountryId":1,
      "CityId": cityId,
      "FBKey":fcmToken.toString(),
      "lang": lng
    };

    http.Response response = await http.post(apiUrl,body:jsonEncode(mapDate),headers: {
      "Accept-Language": LocalizationService.getCurrentLocale().languageCode,
      "Accept": "application/json",
      "content-type": "application/json",
    });
    print('Req: ------------------------');
    print(jsonEncode(mapDate));

    print('ResAll: ------------------------');
    print(response);

    print('Res: ------------------------');
    print(response.body);

    return response;
  }
  MyFirebase myFirebase = MyFirebase();
  BuildContext? context;
  MyAPI({this.context});

  Future<String?> _getDeviceId() async {
    try{
      String? _deviceId = await PlatformDeviceId.getDeviceId;
      return _deviceId;

    }catch(e){

    }
    /*var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if(Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.deviceInfo;
      return "androidDeviceInfo.id"; // unique ID on Android
    }*/
  }

  login(email , password) async{
    var fcmToken;
    try{
      fcmToken = await myFirebase.getToken();
      print(fcmToken);
      print(fcmToken);
    }
    catch(e){
      fcmToken='';
      print(e);
      flushBar(e.toString());
    }
    try{
      http.Response response = await http.post(
          Uri.parse('$_baseUrl/api/Auth/login?'),
          body: jsonEncode({"UserName": email, "Password": password, "FBKey":fcmToken.toString(), "lang": lng}),
          headers: {
            "Accept-Language": LocalizationService.getCurrentLocale().languageCode,
            "Accept": "application/json",
            "content-type": "application/json",
          });
      //await Hive.initFlutter();
      //Hive.registerAdapter(TransactionAdapter());
      //await Hive.openBox<Transaction>('transactions');
      //print(email + ',' + password);
      //print(jsonDecode(response.body));
      if(response.statusCode == 200){
        print(jsonDecode(response.body));
        if(jsonDecode(response.body)['error_des'] == "" || jsonDecode(response.body)['error_des'] == null){
          token = await jsonDecode(response.body)['content']['token'];
          userData = await jsonDecode(response.body)['content'];//id , email, name, token, fbKey
          editTransactionUserData();
          await readUserInfo(userData['id']);
          await userLang(lng, userData['id']);
          return true;
        }
        else{
          flushBar(jsonDecode(response.body)['error_des']);
          return false;
        }
      }
      else if(response.statusCode == 500){
        flushBar(response.reasonPhrase.toString());
        return false;
      }
      else{
        flushBar(response.reasonPhrase.toString());
        return false;
      }
    }
    catch(e){
      flushBar(AppLocalizations.of(context!)!.translate('please! check your network connection'));
      return false;
      print(e);
    }
  }

  userLang(langNum , id) async{
    try{
      http.Response response = await http.post(
          Uri.parse('$_baseUrl/SignUp/UserLang_Update'),
          body: jsonEncode({"intParam": langNum.toString(), "guidParam": id.toString()}),
          headers: {
            //"Accept-Language": LocalizationService.getCurrentLocale().languageCode,
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": token,
          });
      print(response.body);
    }
    catch(e){
      flushBar(AppLocalizations.of(context!)!.translate('please! check your network connection'));
      print(e);
    }
  }

  ver(value, code)async{
    var apiUrl = Uri.parse('$_baseUrl/SignUp/SignUp_Verify');
    Map mapDate = {
      "guidParam": value,
      "txtParam": code,
    };
    http.Response response = await http.post(apiUrl, body: jsonEncode(mapDate), headers: {
      "Accept": "application/json",
      "content-type": "application/json",
    });
    print(response.statusCode);
    print(response.body);
    return response;
/*
    if (response.statusCode == 200) {
      print(response.body);
/*      try {
        if (jsonDecode(response.body)["Data"][0]['txtParam'].toString() ==
            code) {

          http.Response response = await http.post(
              Uri.parse('https://mr-service.online/api/Auth/login'),
              body: jsonEncode({"UserName": email, "Password": password}),
              headers: {
                "Accept": "application/json",
                "content-type": "application/json",
              });
          if (response.statusCode == 200) {
            print(response.body);
            setState(() {
              if (jsonDecode(response.body)['error_des'] == "") {
               var tokenn =
                    jsonDecode(response.body)["content"]["Token"].toString();
                getServiceData(tokenn);

              }
            });
          }




        }
      } catch (e) {
        if (jsonDecode(response.body)['success'].toString() == "false") {
          setState(() => chVer = false);

          Flushbar(
            icon: Icon(
              Icons.error_outline,
              size: 32,
              color: Colors.white,
            ),
            duration: Duration(seconds: 3),
            shouldIconPulse: false,
            flushbarPosition: FlushbarPosition.TOP,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            backgroundColor: Colors.grey.withOpacity(0.5),
            barBlur: 20,
            message: 'Wrong Code'.tr,
          ).show(context);
        }
      }*/
      // Navigator.of(context).pushNamed('sign_in');
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder:(context)=>SignIn()));
    } else {
      //Navigator.of(context).pushNamed('main_screen');
      print(response.statusCode);
      print('A network error occurred');
    }
*/
  }

  void resend(email) async{
    // curl -X POST "https://mr-service.online/Main/SignUp/ReSendVerificationCode?UserEmail=www.osh.themyth%40gmail.com" -H "accept: */*"
    var apiUrl = Uri.parse('$_baseUrl/SignUp/ReSendVerificationCode?UserEmail=$email');
    http.Response response = await http.post(apiUrl, headers: {
      "Accept-Language": LocalizationService.getCurrentLocale().languageCode,
      "Accept": "application/json",
    });
    print(jsonDecode(response.body).toString());
    if (response.statusCode == 200) {
      print("we're good");
      //userData = jsonDecode(response.body);
      if (jsonDecode(response.body)['Errors'] == "") {
        flushBar(jsonDecode(response.body)['Errors']);
          /* Navigator.of(context).pushNamed('sign_in');
          Flushbar(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height / 30),
            icon: Icon(
              Icons.error_outline,
              size: MediaQuery.of(context).size.height / 30,
              color: MyColors.White,
            ),
            duration: Duration(seconds: 3),
            shouldIconPulse: false,
            flushbarPosition: FlushbarPosition.TOP,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            backgroundColor: Colors.grey.withOpacity(0.5),
            barBlur: 20,
            message: jsonDecode(response.body)['Errors'],
            messageSize: MediaQuery.of(context).size.height / 37,
          ).show(context);*/
          //isLogIn = true;
          //token = jsonDecode(response.body)["content"]["Token"].toString();
          //updateUserInfo(userData["content"]["Id"]);
        }
      else {
          //setState(() => chLogIn = false);
        flushBar(jsonDecode(response.body)['Errors']);
        }

    }
    else {
      print(response.statusCode);
      print('A network error occurred');
    }
  }

  getCities() async{
    try{
      http.Response response = await http.get(
          Uri.parse('$_baseUrl/City/City_Read?'),
          //body: jsonEncode({"UserName": email, "Password": password, "FBKey":fcmToken.toString()}),
          headers: {
            "Accept-Language": LocalizationService.getCurrentLocale().languageCode,
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": token,
          });
      //await Hive.initFlutter();
      //Hive.registerAdapter(TransactionAdapter());
      //await Hive.openBox<Transaction>('transactions');
      //print(email + ',' + password);
      if(response.statusCode == 200){
        print(jsonDecode(response.body));
        if(jsonDecode(response.body)['error_des'] == "" || jsonDecode(response.body)['error_des'] == null){
          cities = jsonDecode(response.body)['data'];
          editTransactionCities();
          return true;
        }
        else{
          flushBar(jsonDecode(response.body)['error_des']);
          return false;
        }
      }
    }
    catch(e){
      flushBar(AppLocalizations.of(context!)!.translate('please! check your network connection'));
      return false;
      print(e);
    }

  }

  getOffers({num}) async{
    num??=0; //0 main , 1 carCare , 2 CarRents
    var uri = Uri.parse('$_baseUrl/Offers/Offers_Read?filter=isActive~eq~true');
    switch(num){
      case 0:
        uri = Uri.parse('$_baseUrl/Offers/Offers_Read?filter=isActive~eq~true');
        break;
      case 1:
        uri = Uri.parse('$_baseUrl/CarCare/CarCare_Read?filter=isActive~eq~true');
        break;
      case 2:
        uri = Uri.parse('$_baseUrl/CarRents/CarRents_Read?filter=isActive~eq~true');
        break;
    }
    try{
      http.Response response = await http.get(
          uri,
          //body: jsonEncode({"UserName": email, "Password": password, "FBKey":fcmToken.toString()}),
          headers: {
            "Accept-Language": LocalizationService.getCurrentLocale().languageCode,
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": token,
          });
      //await Hive.initFlutter();
      //Hive.registerAdapter(TransactionAdapter());
      //await Hive.openBox<Transaction>('transactions');
      //print(email + ',' + password);
      print(num.toString());
      if(response.statusCode == 200){
        print(jsonDecode(response.body));
        if(jsonDecode(response.body)['errors'] == "" || jsonDecode(response.body)['errors'] == null){
          offers = jsonDecode(response.body)['data'];
          editTransactionOffers();
          return true;
        }
        else{
          flushBar(jsonDecode(response.body)['errors']);
          return false;
        }
      }
    }
    catch(e){
      flushBar(AppLocalizations.of(context!)!.translate('please! check your network connection'));
      return false;
      print(e);
    }

  }

  getExhibtion() async{
    var uri = Uri.parse('$_baseUrl/Galleries/Galleries_Read?filter=isActive~eq~true');
    try{
      http.Response response = await http.get(
          uri,
          //body: jsonEncode({"UserName": email, "Password": password, "FBKey":fcmToken.toString()}),
          headers: {
            "Accept-Language": LocalizationService.getCurrentLocale().languageCode,
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": token,
          });
      //await Hive.initFlutter();
      //Hive.registerAdapter(TransactionAdapter());
      //await Hive.openBox<Transaction>('transactions');
      //print(email + ',' + password);
      if(response.statusCode == 200){
        print(jsonDecode(response.body));
        if(jsonDecode(response.body)['errors'] == "" || jsonDecode(response.body)['errors'] == null){
          exhibtions = jsonDecode(response.body)['data'];
          //editTransactionOffers();
          return true;
        }
        else{
          flushBar(jsonDecode(response.body)['errors']);
          return false;
        }
      }
    }
    catch(e){
      flushBar(AppLocalizations.of(context!)!.translate('please! check your network connection'));
      return false;
      print(e);
    }

  }


  getBrands({country}) async{
    try{
      http.Response response = await http.get(
          Uri.parse('$_baseUrl/Brands/Brands_Read?filter=isActive~eq~true'),
          //body: jsonEncode({"UserName": email, "Password": password, "FBKey":fcmToken.toString()}),
          headers: {
            "Accept-Language": LocalizationService.getCurrentLocale().languageCode,
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": token,
          });
      //await Hive.initFlutter();
      //Hive.registerAdapter(TransactionAdapter());
      //await Hive.openBox<Transaction>('transactions');
      //print(email + ',' + password);
      if(response.statusCode == 200){
        print(jsonDecode(response.body));
        if(jsonDecode(response.body)['error_des'] == "" || jsonDecode(response.body)['error_des'] == null){
          brands = jsonDecode(response.body)['data'];
          editTransactionBrands();
          if(country != null) brands.removeWhere((element) => element['brandsCountry']['name'] != country);
          return true;
        }
        else{
          flushBar(jsonDecode(response.body)['error_des']);
          return false;
        }
      }
    }

    catch(e){
      flushBar(AppLocalizations.of(context!)!.translate('please! check your network connection'));
      return false;
      print(e);
    }
  }

  getGarageBrands() async{
    try{
      http.Response response = await http.get(
          //Uri.parse('$_baseUrl/GaragBrands/GaragBrands_Read?filter=isActive~eq~true'),
          Uri.parse('$_baseUrl/GaragBrands/GaragBrands_Read?filter=isActive~eq~true'),
          //body: jsonEncode({"UserName": email, "Password": password, "FBKey":fcmToken.toString()}),
          headers: {
            "Accept-Language": LocalizationService.getCurrentLocale().languageCode,
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": token,
          });
      //await Hive.initFlutter();
      //Hive.registerAdapter(TransactionAdapter());
      //await Hive.openBox<Transaction>('transactions');
      //print(email + ',' + password);
      if(response.statusCode == 200){
        print(jsonDecode(response.body));
        if(jsonDecode(response.body)['error_des'] == "" || jsonDecode(response.body)['error_des'] == null){
          brands = jsonDecode(response.body)['data'];
          editTransactionBrands();
          return true;
        }
        else{
          flushBar(jsonDecode(response.body)['error_des']);
          return false;
        }
      }
    }
    catch(e){
      flushBar(AppLocalizations.of(context!)!.translate('please! check your network connection'));
      return false;
      print(e);
    }

  }

  getBrandsCountry() async{
    try{
      http.Response response = await http.get(
          //Uri.parse('$_baseUrl/GaragBrands/GaragBrands_Read?filter=isActive~eq~true'),
          Uri.parse('$_baseUrl/BrandsCountry/BrandsCountry_Read?filter=isActive~eq~true'),
          //body: jsonEncode({"UserName": email, "Password": password, "FBKey":fcmToken.toString()}),
          headers: {
            "Accept-Language": LocalizationService.getCurrentLocale().languageCode,
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": token,
          });
      //await Hive.initFlutter();
      //Hive.registerAdapter(TransactionAdapter());
      //await Hive.openBox<Transaction>('transactions');
      //print(email + ',' + password);
      if(response.statusCode == 200){
        print(jsonDecode(response.body));
        if(jsonDecode(response.body)['error_des'] == "" || jsonDecode(response.body)['error_des'] == null){
          brandsCountry = jsonDecode(response.body)['data'];
          editTransactionBrandsCountry();
          return true;
        }
        else{
          flushBar(jsonDecode(response.body)['error_des']);
          return false;
        }
      }
    }
    catch(e){
      flushBar(AppLocalizations.of(context!)!.translate('please! check your network connection'));
      return false;
      print(e);
    }


  }

  getSupliers(id, brabd, {bool? original, bool? afterMarket, indexGarage, bool? perBrand}) async{
    print(brabd+'   $id');
    perBrand ??= false;
    //var uri = Uri.parse("$_baseUrl/Suppliers/Suppliers_Read?");
    var uri = Uri.parse("$_baseUrl/Suppliers/Suppliers_Read?filter=$brabd~eq~true");
    if(perBrand) uri = Uri.parse("$_baseUrl/Suppliers/SuppliersByBrands_Read?brandId='$id'filter=$brabd~eq~true");
    //if(perBrand) uri = Uri.parse("$_baseUrl/Suppliers/SuppliersByBrands_Read?brandid='$id'filter=$brabd~eq~true");
    if(perBrand) {
      var s = "$_baseUrl/Suppliers/SuppliersByBrands_Read?brandid=$id";
      uri = Uri.parse(s);
    }
    try{
      http.Response response = await http.get(
          uri,
          //Uri.parse("$_baseUrl/Suppliers/Suppliers_Read?filter=id~eq~'$id'~and~$brabd~eq~true"),
          //!perBrand? Uri.parse("$_baseUrl/Suppliers/Suppliers_Read?filter=$brabd~eq~true")
          //Uri.parse("$_baseUrl/Suppliers/Suppliers_Read?"),
          //: Uri.parse("$_baseUrl/Suppliers/SuppliersByBrands_Read?brandId='$id'filter=$brabd~eq~true"),
          //body: jsonEncode({"UserName": email, "Password": password, "FBKey":fcmToken.toString()}),
          headers: {
            "Accept-Language": LocalizationService.getCurrentLocale().languageCode,
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": token,
          });
      //await Hive.initFlutter();
      //Hive.registerAdapter(TransactionAdapter());
      //await Hive.openBox<Transaction>('transactions');
      //print(email + ',' + password);
      print('testSup');
      if(response.statusCode == 200){
        print(jsonDecode(response.body));
        if(jsonDecode(response.body)['error_des'] == "" || jsonDecode(response.body)['error_des'] == null){
          /*suplierList.add(
            {
              "id": 2,
              "fullName": "string",
              "spareParts": true,
              "garages": true,
              "scraps": true,
              "batteries": true,
              "mobiles": true,
              "orginal": true,
              "aftermarket": true,
              "urgentBattery": true,
              "garagBody": true,
              "garagMechanical": true,
              "garagElectrical": true,
              "garagCustomization": true,
              "rating": 0,
              "logo": "string"
            }
          );
          */
          if(perBrand){
            suplierList.clear();
            var k = jsonDecode(response.body)['total'];
            for(int i = 0; i< k; i++){
              if(jsonDecode(response.body)['data'][i]['suppliers'][brabd.toString()] == true) {
                suplierList.add(jsonDecode(response.body)['data'][i]['suppliers']);
              }
            }
          }else{
            suplierList = jsonDecode(response.body)['data'];
          }
          if(original!) {
            suplierList.removeWhere((element) => element['original'] == false);
          } else if(afterMarket!) {
            suplierList.removeWhere((element) => element['aftermarket'] == false);
          }
          if(brabd=='garages'){
            if(indexGarage == 1) {
              suplierList.removeWhere((element) => element['garagMechanical'] == false);
            } else if(indexGarage == 2) {
              suplierList.removeWhere((element) => element['garagElectrical'] == false);
            } else if(indexGarage == 3) {
              suplierList.removeWhere((element) => element['garagCustomization'] == false);
            }
          }
          editTransactionSuplierList();
          return true;
        }
        else{
          flushBar(jsonDecode(response.body)['error_des']);
          return false;
        }
      }
    }
    catch(e){
      flushBar(AppLocalizations.of(context!)!.translate('please! check your network connection'));
      return false;
      print(e);
    }

  }

  getOrders(id) async{
    //var url = "$_baseUrl/Orders/Orders_Read?";
    print('omar');
    var url = "$_baseUrl/Orders/Orders_Read?filter=customerId~eq~'$id'";
    print(url.toString());
    //var url = "$_baseUrl/Orders/Orders_Read?";
    if(userInfo['type'] == 1) url = "$_baseUrl/Orders/Suppliers_Orders_Read?userid=$id";
    try{
      print('$id');
      print('$id');
      http.Response response = await http.get(
          //Uri.parse("$_baseUrl/Suppliers/Suppliers_Read?filter=id~eq~'$id'~and~$brabd~eq~true"),
          Uri.parse(url),
          //Uri.parse("$_baseUrl/Orders/Orders_Read?"),
          headers: {
            "Accept-Language": LocalizationService.getCurrentLocale().languageCode,
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": token,
          });
      if(response.statusCode == 200){
        print(jsonDecode(response.body));
        if(jsonDecode(response.body)['errors'] == "" || jsonDecode(response.body)['errors'] == null){
          ordersList = jsonDecode(response.body)['data'];
          editTransactionOrdersList();
          return true;
        }
        else{
          flushBar(jsonDecode(response.body)['Errors']);
          return false;
        }
      }
    }
    catch(e){
      flushBar(AppLocalizations.of(context!)!.translate('please! check your network connection'));
      return false;
      print(e);
    }

  }

  getCarSell(String _brandId) async{
    //var url = "$_baseUrl/Orders/Orders_Read?";
    print('Car sell');
    var url = "$_baseUrl/CarSell/CarSell_Read";
    if(_brandId.isNotEmpty) url = "$_baseUrl/CarSell/CarSell_Read?filter=brandId~eq~'$_brandId'";
    print(url.toString());
    //var url = "$_baseUrl/Orders/Orders_Read?";
    try{
      http.Response response = await http.get(
        //Uri.parse("$_baseUrl/Suppliers/Suppliers_Read?filter=id~eq~'$id'~and~$brabd~eq~true"),
          Uri.parse(url),
          //Uri.parse("$_baseUrl/Orders/Orders_Read?"),
          headers: {
            "Accept-Language": LocalizationService.getCurrentLocale().languageCode,
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": token,
          });
      if(response.statusCode == 200){
        print(jsonDecode(response.body));
        if(jsonDecode(response.body)['errors'] == "" || jsonDecode(response.body)['errors'] == null){
          carSellsList = jsonDecode(response.body)['data'];
          //editTransactionOrdersList();
          return true;
        }
        else{
          flushBar(jsonDecode(response.body)['Errors']);
          return false;
        }
      }
    }
    catch(e){
      flushBar(AppLocalizations.of(context!)!.translate('please! check your network connection'));
      return false;
      print(e);
    }

  }

  getCarBroadKey(String _brandId) async{
    //var url = "$_baseUrl/Orders/Orders_Read?";
    print('Car sell');
    var url = "$_baseUrl/CarKey/CarKey_Read";
    if(_brandId.isNotEmpty) url = "$_baseUrl/CarKey/CarKey_Read?filter=carKeyType~eq~'$_brandId'";
    print(url.toString());
    //var url = "$_baseUrl/Orders/Orders_Read?";
    try{
      http.Response response = await http.get(
        //Uri.parse("$_baseUrl/Suppliers/Suppliers_Read?filter=id~eq~'$id'~and~$brabd~eq~true"),
          Uri.parse(url),
          //Uri.parse("$_baseUrl/Orders/Orders_Read?"),
          headers: {
            "Accept-Language": LocalizationService.getCurrentLocale().languageCode,
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": token,
          });
      if(response.statusCode == 200){
        print(jsonDecode(response.body));
        if(jsonDecode(response.body)['errors'] == "" || jsonDecode(response.body)['errors'] == null){
          carBroadKeyList = jsonDecode(response.body)['data'];
          //editTransactionOrdersList();
          return true;
        }
        else{
          flushBar(jsonDecode(response.body)['Errors']);
          return false;
        }
      }
    }
    catch(e){
      flushBar(AppLocalizations.of(context!)!.translate('please! check your network connection'));
      return false;
      print(e);
    }

  }

  getCarModel() async{
    //var url = "$_baseUrl/Orders/Orders_Read?";
    print('Car model');
    var url = "$_baseUrl/CarModels/CarModels_Read";
    print(url.toString());
    //var url = "$_baseUrl/Orders/Orders_Read?";
    try{
      http.Response response = await http.get(
        //Uri.parse("$_baseUrl/Suppliers/Suppliers_Read?filter=id~eq~'$id'~and~$brabd~eq~true"),
          Uri.parse(url),
          //Uri.parse("$_baseUrl/Orders/Orders_Read?"),
          headers: {
            "Accept-Language": LocalizationService.getCurrentLocale().languageCode,
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": token,
          });
      if(response.statusCode == 200){
        print(jsonDecode(response.body));
        if(jsonDecode(response.body)['errors'] == "" || jsonDecode(response.body)['errors'] == null){
          carModelList = jsonDecode(response.body)['data'];
          //editTransactionOrdersList();
          return true;
        }
        else{
          flushBar(jsonDecode(response.body)['Errors']);
          return false;
        }
      }
    }
    catch(e){
      flushBar(AppLocalizations.of(context!)!.translate('please! check your network connection'));
      return false;
      print(e);
    }

  }

  flushBar(text){
    try{
      Flushbar(
        margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context!).size.width/20, vertical: MediaQuery.of(context!).size.width/20*0),
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context!).size.height / 30),
        icon: Icon(
          Icons.error_outline,
          size: MediaQuery.of(context!).size.height / 30,
          color: MyColors.white,
        ),
        duration: const Duration(seconds: 3),
        shouldIconPulse: false,
        flushbarPosition: FlushbarPosition.TOP,
        borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context!).size.height / 30/2)),
        backgroundColor: Colors.grey.withOpacity(0.5),
        barBlur: 20,
        message: text,
        messageText: Text(text,
          style: const TextStyle(
            fontFamily: 'Gotham',
            color: MyColors.white,
          ),
        ),
        //flushbarStyle: FlushbarStyle.FLOATING,
        messageSize: MediaQuery.of(context!).size.width / 30,
      ).show(context!);
    }catch(e){
      print(e.toString());
    }
  }

  Future sendEmail(String _body, String _subject, String _recipient) async {
    //String username = 'auto22mall20@gmail.com';
    String username = 'auto20mall22@gmail.com';
    String password = 'Am@123456';
    //String password = 'AM@123456';
    bool platformResponse = false;
    // ignore: deprecated_member_use
    final smtpServer = gmail(username, password);
    // Use the SmtpServer class to configure an SMTP server:
    // final smtpServer = SmtpServer('smtp.domain.com');
    // See the named arguments of SmtpServer for further configuration
    // options.

    // Create our message.
    final message = Message()
      ..from = Address(username, _subject)
      ..recipients.add(_recipient)
      //..ccRecipients.addAll(['destCc1@example.com', 'destCc2@example.com'])
      //..bccRecipients.add(Address('bccAddress@example.com'))
      ..subject = AppLocalizations.of(context!)!.translate('name')
      //..text = 'This is the plain text.\n$_body.'
      ..html = "<h1>${AppLocalizations.of(context!)!.translate('Congratulations')}</h1>\n<p>$_body</p>";
    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      platformResponse = true;
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      platformResponse = false;
    }
/*
    bool isHTML = false;
    final Email email = Email(
      body: _body,
      subject: _subject,
      recipients: [_recipient],
      //attachmentPaths: attachments,
      //cc: ['cc@example.com'],
      //bcc: ['bcc@example.com'],
      isHTML: isHTML,
    );
    try {
      await FlutterEmailSender.send(email);
      platformResponse = true;
    } catch (error) {
      print(error);
      platformResponse = false;
    }*/

    var fcmToken;
    try{
      fcmToken = await myFirebase.getToken();
      platformResponse = true;
      print(fcmToken);
    }
    catch(e){
      fcmToken='';
      print(e);
      platformResponse = false;
      //flushBar(e.toString());
    }
    await _sendPushMessage(_body, _subject, fcmToken);
    return platformResponse;
  }

  Future<void> _sendPushMessage(body, title, _token) async {
    String constructFCMPayload(String? token, _title, _body) {
      return jsonEncode({
        'to': token,
        'data': {
          //'to': token,
          //"registration_ids" : token,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'type': 'COMMENT',
          'via': 'FlutterFire Cloud Messaging!!!',
          //'count': _messageCount.toString(),
        },
        'notification': {
          'title': _title,
          'body': _body,
        },
      });
    }
    if (_token == null || _token == 'lastName') {
      print('Unable to send FCM message, no token exists.');
      return;
    }
    try {
      var _serverKey = 'AAAAMwglvWs:APA91bHsPk8XkZsd4YE3mdQsGSJDPlwB_DwXt150mupjJ-CpujuI69ardOGDyM0sQ608LN5oxlS4DkIgloHg5MGGZkCepZudg2PfsfylJnbiPaern8MHCQG66B5XZhi9yomLwRJbz9jM';
      var response = await http.post(
        //Uri.parse('https://api.rnfirebase.io/messaging/send'),
        //Uri.parse('https://fcm.googleapis.com/v1/projects/mr-services-15410/messages:send'),
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=$_serverKey',
          'project_id':'219180023147',
        },
        body: constructFCMPayload(_token, title, body),
      );
      print('FCM request for device sent!');
      print(jsonEncode(response.body));
      print(response.statusCode);
    } catch (e) {
      print(e);
    }
  }

  Future readUserInfo(var id) async {
    try{
      print("flag1");
      print("$_baseUrl/SignUp/SignUp_Read?filter=id~eq~'$id'");
      var url = Uri.parse("$_baseUrl/SignUp/SignUp_Read?filter=id~eq~'$id'");
      //var url = Uri.parse("$_baseUrl/SignUp/SignUp_Read?filter=id~eq~'46438c59-63c6-47af-2cd3-08da1c725dd8'");
      //var url = Uri.parse("$_baseUrl/SignUp/SignUp_Read?");
      //var url = Uri.parse("$_baseUrl/SignUp/SignUp_ReadById");
      http.Response response = await http.get(
        url,
        //body: jsonEncode({"UserName": "email", "Password": "password", "FBKey":"fcmToken.toString()"}),
        headers: {
         // "Accept-Language": LocalizationService.getCurrentLocale().languageCode,
         // "Accept": "application/json",
         // "content-type": "application/json",
          "Authorization": token,
        },
      );
      print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        print("flag2");
        //print(jsonDecode(response.body)['result'].length.toString());
        var k = jsonDecode(response.body)['result']['total'];
        print(k.toString());
        userInfo = jsonDecode(response.body)['result']['data'][0];
        for(int i = 0; i < k; i++){
          print(jsonDecode(response.body)['result']['data'][i]['name']);
          if(id == jsonDecode(response.body)['result']['data'][i]['id']){
            userInfo = jsonDecode(response.body)['result']['data'][i];
            i=k;
          }
        }
        await editTransactionUserInfo();
        print(userInfo);
        nameController.text = userInfo['name'];
        mobileController.text = userInfo['mobile']; //userInfo['mobile'];
        cityController.text = userInfo['city']['name']; //userInfo['city'];

        print("flag3");
      } else {
        print("flag4");
        print(response.statusCode);
      }
      print("flag5");
      //await Future.delayed(Duration(seconds: 1));
    }catch(e){
      print('check network connection\n' + e.toString());
    }
  }

  Future updateProfile() async {
    var apiUrl = Uri.parse('$_baseUrl/SignUp/SignUp_UpdateInfo?');
    var request = http.MultipartRequest('POST', apiUrl);
    request.fields['Id'] = userData["id"];
    request.fields['Name'] = nameController.text;
    request.fields['LastName'] = 'empty';
    request.fields['Mobile'] = mobileController.text;
    request.fields['Email'] = userInfo["email"];
    request.fields['Password'] = userInfo["password"];
    //request.fields['Type'] = userInfo["Type"].toString();
    print(path);
    print(request.fields);
    print(token);
    if (path != "") {
      print("############################");
      try{
        request.files.add(await http.MultipartFile.fromPath('File', path as String),);
      }catch(e){
        print(e.toString());
      }
      print(path);
    }
    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-type": "multipart/form-data",
      "Authorization": token,
    };
    request.headers.addAll(headers);
    var response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      await readUserInfo(userData["id"]);
      print('success');
      flushBar(AppLocalizations.of(context!)!.translate('Your profile data is updated'));
    } else {
      print(response.statusCode);
      print('fail');
      flushBar(AppLocalizations.of(context!)!.translate("Your profile data Can't be updated"));
    }
  }

  Future orderCreate(id, catigoryId, brandId, vinNumber, carName, carModel, remaks, List attach,List supplier, indexGarage) async{
    try{
      //await _sendPushMessage(AppLocalizations.of(context!)!.translate('you have new order, show it and send your offer'), AppLocalizations.of(context!)!.translate('New Order') /*+ ' ' + jsonDecode(response.body)['data']['serial']*/, supplier[0]['user']['fbKey']);
      var  apiUrl =Uri.parse('$_baseUrl/Orders/Orders_Create');
      //var s = 1;
      print(supplier.toString());
      String insertDateTime = DateFormat('yyyy-MM-dd hh:mm:ss.sss').format(DateTime.now().add(timeDiff)).replaceAll(" ", "T") + "Z";
      List orderSuppliers=[];
      orderSuppliers.clear();
      for(int i = 0; i < supplier.length; i++){
        print(supplier[i]['id'].toString());
        orderSuppliers.add(
            {
              //"id": 0,
              "supplierId": supplier[i]['id'],
              //"suppliers": supplier[i],
              //"orderId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
              //"status": 1,
              //"replyDate": "2022-05-30T19:57:07.177Z",
              //"supplierNotes": "string"
            }
        );
      }
      Map mapDate = {
        "customerId": id,
        "categoryId": catigoryId,
        "brandId": brandId.round(),
        "orginalOrAftermarket": true,
        "vinNumber": vinNumber,
        "carName": carName,
        "carModel": carModel,
        "remarks": remaks,
        "insertDate": insertDateTime,
        "garagBody": catigoryId==1?true:false,
        "garagMechanical": catigoryId==1 && indexGarage == 1?true:false,
        "garagElectrical": catigoryId==1 && indexGarage == 2?true:false,
        "garagCustomization": catigoryId==1 && indexGarage == 3?true:false,
        "orderSuppliers": orderSuppliers,
        "firstAttachment": attach.isNotEmpty? attach[0]['name']: null,
        "secondAttachment": attach.length>1? attach[1]['name']: null,
        "thirdAttachment": attach.length>2? attach[2]['name']: null,
        "forthAttachment": attach.length>3? attach[3]['name']: null,
        "fifthAttachment": attach.length>4? attach[4]['name']: null,
        "sixthAttachment": attach.length>5? attach[5]['name']: null,
        "firstAttachmentFile": attach.isNotEmpty? attach[0]['base']: null,
        "secondAttachmentFile": attach.length>1? attach[1]['base']: null,
        "thirdAttachmentFile": attach.length>2? attach[2]['base']: null,
        "forthAttachmentFile": attach.length>3? attach[3]['base']: null,
        "fifthAttachmentFile": attach.length>4? attach[4]['base']: null,
        "sixthAttachmentFile": attach.length>5? attach[5]['base']: null,
      };
      print('Req: ------------------------');
      print(jsonEncode(mapDate));
      http.Response response = await http.post(apiUrl,body:jsonEncode(mapDate),headers: {
        //"Accept-Language": LocalizationService.getCurrentLocale().languageCode,
        "Accept": "application/json",
        "content-type": "application/json",
        "Authorization": token,
      });

      print('ResAll: ------------------------');
      print(response);

      print('Res: ------------------------');
      print(response.body);

      print(token);

      //create multipart request for POST or PATCH method
      //add text fields
      print(response.statusCode);
      if (response.statusCode == 200) {
        //Get the response from the server
        try{
          if (jsonDecode(response.body)['errors'] == null || jsonDecode(response.body)['errors'] == ''){
            print('success');
            flushBar(AppLocalizations.of(context!)!.translate('Your request is added'));
            for(int i = 0; i < supplier.length; i++){
              await _sendPushMessage(AppLocalizations.of(context!)!.translate('you have new order, show it and send your offer'), AppLocalizations.of(context!)!.translate('New Order') /*+ ' ' + jsonDecode(response.body)['data']['serial']*/, supplier[i]['user']['fbKey']);
            }
            return true;
          }else{
            flushBar(jsonDecode(response.body)['errors']);
            return false;
          }
        }catch(e){
          flushBar(e.toString());
          return false;
        }
      } else {
        flushBar(jsonDecode(response.body)['Errors']);
        return false;
        print(response.statusCode);
      }
    }catch(e){
      flushBar(e.toString());
      return false;
    }
/*
    {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "grageBrandId": 0,
    "urgentBattery": true,
    "garagBody": true,
    "garagMechanical": true,
    "garagElectrical": true,
    "garagCustomization": true,

"orderSuppliers": [
    {
      "id": 0,
      "supplierId": 0,
      "suppliers": {
        "id": 0,
        "fullName": "string",
        "spareParts": true,
        "garages": true,
        "scraps": true,
        "batteries": true,
        "mobiles": true,
        "orginal": true,
        "aftermarket": true,
        "urgentBattery": true,
        "garagBody": true,
        "garagMechanical": true,
        "garagElectrical": true,
        "garagCustomization": true,
        "rating": 0,
        "logo": "string"
      },
      "orderId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "status": 0,
      "replyDate": "2022-05-17T06:18:26.218Z",
      "supplierNotes": "string"
    }
  ]
    "status": 0,
    "serial": 0,
    "endDate": "2022-04-28T14:35:52.415Z",
    "user": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "name": "string",
    "lastName": "string",
    "mobile": "string",
    "email": "string",
    "password": "string",
    "verificationCode": "string",
    "isVerified": true,
    "type": 0,
    "dob": "2022-04-28T14:35:52.415Z",
    "imagePath": "string",
    "file": "string",
    "eventDate": "2022-04-28T14:35:52.415Z",
    "fbKey": "string",
    "lang": 0,
    "countryId": 0,
    "country": {
    "id": 0,
    "name": "string",
    "isActive": true,
    "city": [
    {
    "id": 0,
    "name": "string",
    "countryId": 0,
    "isActive": true,
    "users": [
    null
    ]
    }
    ],
    "users": [
    null
    ]
    },
    "cityId": 0,
    "city": {
    "id": 0,
    "name": "string",
    "countryId": 0,
    "isActive": true,
    "users": [
    null
    ]
    }
    }
    }
  */
  }

  Future orderClose(id) async{
    try{
      var  apiUrl =Uri.parse('$_baseUrl/Orders/Orders_Close');
      //var s = 1;
      String insertDateTime = DateFormat('yyyy-MM-dd hh:mm:ss.sss').format(DateTime.now().add(timeDiff)).replaceAll(" ", "T") + "Z";
      Map mapDate = {
        "id": id,
        "endDate": insertDateTime,
        "status": 2
      };
      print('Req: ------------------------');
      print(jsonEncode(mapDate));
      http.Response response = await http.post(apiUrl,body:jsonEncode(mapDate),headers: {
        //"Accept-Language": LocalizationService.getCurrentLocale().languageCode,
        "Accept": "application/json",
        "content-type": "application/json",
        "Authorization": token,
      });

      print('ResAll: ------------------------');
      print(response);

      print('Res: ------------------------');
      print(response.body);

      print(token);

      //create multipart request for POST or PATCH method
      //add text fields
      print(response.statusCode);
      if (response.statusCode == 200) {
        //Get the response from the server
        try{
          if (jsonDecode(response.body)['Errors'] == null || jsonDecode(response.body)['Errors'] == ''){
            print('success');
            flushBar(AppLocalizations.of(context!)!.translate('this order was closed!'));
            return true;
          }else{
            flushBar(jsonDecode(response.body)['Errors']);
            return false;
          }
        }catch(e){
          return false;
        }
      } else {
        flushBar(jsonDecode(response.body)['Errors']);
        return false;
        print(response.statusCode);
      }

    }catch(e){
      return false;
    }
  }

  Future orderSupplierWin(orderId, supplierId, suppFBkey, orderSerial) async{
    try{
      var  apiUrl =Uri.parse('$_baseUrl/Orders/Orders_Suppliers_Win');
      //var s = 1;
      String insertDateTime = DateFormat('yyyy-MM-dd hh:mm:ss.sss').format(DateTime.now().add(timeDiff)).replaceAll(" ", "T") + "Z";
      Map mapDate = {
        "orderId": orderId,
        "supplierId": supplierId
      };
      print('Req: ------------------------');
      print(jsonEncode(mapDate));
      http.Response response = await http.post(apiUrl,body:jsonEncode(mapDate),headers: {
        //"Accept-Language": LocalizationService.getCurrentLocale().languageCode,
        "Accept": "application/json",
        "content-type": "application/json",
        "Authorization": token,
      });

      print('ResAll: ------------------------');
      print(response);

      print('Res: ------------------------');
      print(response.body);

      print(token);

      //create multipart request for POST or PATCH method
      //add text fields
      print(response.statusCode);
      if (response.statusCode == 200) {
        //Get the response from the server
        try{
          if (jsonDecode(response.body)['Errors'] == null || jsonDecode(response.body)['Errors'] == ''){
            print('success');
            flushBar(AppLocalizations.of(context!)!.translate('The Order is finished by selecting this supplier'));
            await _sendPushMessage(AppLocalizations.of(context!)!.translate('the customer submitted your offer, email it'), AppLocalizations.of(context!)!.translate('Win offer') + ' $orderSerial', suppFBkey);
            return true;
          }else{
            flushBar(jsonDecode(response.body)['Errors']);
            return false;
          }
        }catch(e){
          return false;
        }
      } else {
        flushBar(jsonDecode(response.body)['Errors']);
        return false;
        print(response.statusCode);
      }

    }catch(e){
      return false;
    }
  }

  Future orderRate(orderId, rateScore, suppFBkey) async{
    try{
      var  apiUrl =Uri.parse('$_baseUrl/Orders/Orders_Rate?');
      //var s = 1;
      String insertDateTime = DateFormat('yyyy-MM-dd hh:mm:ss.sss').format(DateTime.now().add(timeDiff)).replaceAll(" ", "T") + "Z";
      Map mapDate = {
        "orderId": orderId,
        "rateNote": "string",
        "rateScore": rateScore
      };
      print('Req: ------------------------');
      print(jsonEncode(mapDate));
      http.Response response = await http.post(apiUrl,body:jsonEncode(mapDate),headers: {
        //"Accept-Language": LocalizationService.getCurrentLocale().languageCode,
        "Accept": "application/json",
        "content-type": "application/json",
        "Authorization": token,
      });

      print('ResAll: ------------------------');
      print(response);

      print('Res: ------------------------');
      print(response.body);

      print(token);

      //create multipart request for POST or PATCH method
      //add text fields
      print(response.statusCode);
      if (response.statusCode == 200) {
        //Get the response from the server
        try{
          if (jsonDecode(response.body)['Errors'] == null || jsonDecode(response.body)['Errors'] == ''){
            print('success');
            flushBar(AppLocalizations.of(context!)!.translate('the score is saved to this order'));
            //_sendPushMessage(AppLocalizations.of(context!)!.translate('the customer rated your offer, its rate is ') + rateScore.toString(), AppLocalizations.of(context!)!.translate('Rate offer'), suppFBkey);
            return true;
          }else{
            flushBar(jsonDecode(response.body)['Errors']);
            return false;
          }
        }catch(e){
          return false;
        }
      } else {
        flushBar(jsonDecode(response.body)['Errors']);
        return false;
        print(response.statusCode);
      }

    }catch(e){
      return false;
    }
  }

  Future orderSupplierUpdate(supplierId, orderId, notes, attachment, {orderSerial, costomerFBkey, id, isWinner, score, scoreNote, int? statue}) async{
   try{
     var  apiUrl =Uri.parse('$_baseUrl/Orders/Orders_Suppliers_Update');
     //if(statue == null) statue=1;
     //var s = 1;
     String insertDateTime = DateFormat('yyyy-MM-dd hh:mm:ss.sss').format(DateTime.now().add(timeDiff)).replaceAll(" ", "T") + "Z";
     Map mapDate = {
       "id": 0,//id,
       "supplierId": supplierId,
       "orderId": orderId.toString(),
       "status": statue,
       "replyDate": insertDateTime,
       "supplierNotes": notes,
       "replyAttachment": attachment.isNotEmpty? attachment[0]['name']: null,
       "isWinner": isWinner,
       "score": score,
       "scoreNote": scoreNote,
       "replyAttachmentFile": attachment.isNotEmpty? attachment[0]['base']: null
     };
     print('Req: ------------------------');
     print(jsonEncode(mapDate));
     http.Response response = await http.post(apiUrl,body:jsonEncode(mapDate),headers: {
       //"Accept-Language": LocalizationService.getCurrentLocale().languageCode,
       "Accept": "application/json",
       "content-type": "application/json",
       "Authorization": token,
     });

     print('ResAll: ------------------------');
     print(response);

     print('Res: ------------------------');
     print(response.body);

     print(token.toString());

     //create multipart request for POST or PATCH method
     //add text fields
     print(response.statusCode);
     if (response.statusCode == 200) {
       //Get the response from the server
       try{
         if (jsonDecode(response.body)['Errors'] == null || jsonDecode(response.body)['Errors'] == ''){
           print('success');
           flushBar(AppLocalizations.of(context!)!.translate('Your reply is sent'));
           await _sendPushMessage(AppLocalizations.of(context!)!.translate('you have new offer for this order'), 'Reply order $orderSerial', costomerFBkey);
           return true;
         }else{
           flushBar(jsonDecode(response.body)['Errors'].toString());
           return false;
         }
       }catch(e){
         return false;
       }
     } else {
       flushBar(jsonDecode(response.body)['Errors']);
       return false;
       print(response.statusCode);
     }

   }catch(e){
     flushBar(e.toString());
     print(e.toString());
     return false;
   }

  }

  requestResetPassword(email) async {
    http.Response response = await http.post(Uri.parse('$_baseUrl/SignUp/RequestResetPassword?UserEmail=$email'),
        headers: {
          "Authorization": token,
          "accept": "application/json",
        });
    //curl -X POST "https://mr-service.online/Main/SignUp/RequestResetPassword?UserEmail=www.osh.themyth%40gmail.com" -H "accept: */*"
    //curl -X POST "https://mr-service.online/api/Auth/login" -H "accept: text/plain" -H "Content-Type: application/json-patch+json" -d "{\"UserName\":\"www.osh.themyth@gmail.com\",\"Password\":\"0938025347\"}"
    if (response.statusCode == 200) {
      print("we're good");
      print(jsonDecode(response.body));
      userData = jsonDecode(response.body);
      if (jsonDecode(response.body)['errors'] == "") {
        var verificationCode = jsonDecode(response.body)['data'][0];
        return [true,verificationCode];
      }
      else {
          flushBar(jsonDecode(response.body)['errors']);
          return [false];
      }
    }
    else if (response.statusCode == 500){
      flushBar(response.reasonPhrase.toString());
      return [false];
    }
    else {
      flushBar(AppLocalizations.of(context!)!.translate('please! check your network connection'));
      return [false];
    }
    /*if (isLogIn) {
      getServiceData();
    }
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setString('token', token);
*/
  }

  newPasswordVer(String newPassword, email, code) async{
    //curl -X POST "https://mr-service.online/Main/SignUp/ResetPassword?UserEmail=www.osh.themyth2%40gmail.com&code=160679&password=0938025347" -H "accept: */*"
    var apiUrl = Uri.parse('$_baseUrl/SignUp/ResetPassword?UserEmail=$email&code=$code&password=$newPassword');
    http.Response response = await http.post(apiUrl, headers: {
      "Accept": "application/json",
      "Authorization": token,
    });
    if (response.statusCode == 200) {
      print("we're good");
      //userData = jsonDecode(response.body);
      if (jsonDecode(response.body)['errors'] == "") {
          //isLogIn = true;
          //token = jsonDecode(response.body)["content"]["Token"].toString();
          //updateUserInfo(userData["content"]["Id"]);
        Navigator.of(context!).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Sign_in(true),),
              (Route<dynamic> route) => false,
        );
        return true;
        }
      else {
          //setState(() => chLogIn = false);
          flushBar(jsonDecode(response.body)['errors']);
          return false;
        }
    }
    else {
      print(response.statusCode);
      print('A network error occurred');
      return false;
    }

  }

  String getBase64FileExtension(String base64String) {
    switch (base64String.characters.first) {
      case '/':
        return 'jpeg';
      case 'i':
        return 'png';
      case 'R':
        return 'gif';
      case 'U':
        return 'webp';
      case 'J':
        return 'pdf';
      default:
        return 'unknown';
    }
  }

  Future sendSellCar(id, type, brandId, carModel, productionYear, List attach, numberOfCylinders, gearBoxType, kelometrage, price, description,alaminumTires, sunRoof, leatherSeats, navigationMap, nearScreens, camera, motorType) async{
    try{
      var  apiUrl =Uri.parse('$_baseUrl/CarSell/CarSell_Create');
     print('t');
      Map mapDate = {
          //"id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
          "customerId": id,
          "serial": 0,
          "type": type,
          "brandId": brandId,
          "carModelId": carModel,
          "productionYear": productionYear,
          "numberOfCylindes": numberOfCylinders,
          "gearBoxType": gearBoxType,
          "kelometrage": kelometrage.round(),
          "price": price.round(),
          "mainAttachment": attach.isNotEmpty? attach[0]['name']: null,
          "firstAttachment": attach.length>1? attach[1]['name']: null,
          "secondAttachment": attach.length>2? attach[2]['name']: null,
          "thirdAttachment": attach.length>3? attach[3]['name']: null,
        "forthAttachment": attach.length>4? attach[4]['name']: null,
        "fifthAttachment": attach.length>5? attach[5]['name']: null,
        "sixthAttachment": attach.length>6? attach[6]['name']: null,
          "notes": description,
          "mainAttachmentFile": attach.isNotEmpty? attach[0]['base']: null,
          "firstAttachmentFile": attach.length>1? attach[1]['base']: null,
          "secondAttachmentFile": attach.length>2? attach[2]['base']: null,
          "thirdAttachmentFile": attach.length>3? attach[3]['base']: null,
        "forthAttachmentFile": attach.length>4? attach[4]['base']: null,
        "fifthAttachmentFile": attach.length>5? attach[5]['base']: null,
        "sixthAttachmentFile": attach.length>6? attach[6]['base']: null,
        "alloyWheels": alaminumTires,
        "sunRoof": sunRoof,
        "leatherSeats": leatherSeats,
        "navigationMaps": navigationMap,
        "nearScreens": nearScreens,
        "camera": camera,
        "motorType": motorType
      };
      print('Req: ------------------------');
      print(jsonEncode(mapDate));
      http.Response response = await http.post(apiUrl,body:jsonEncode(mapDate),headers: {
        //"Accept-Language": LocalizationService.getCurrentLocale().languageCode,
        "Accept": "application/json",
        "content-type": "application/json",
        "Authorization": token,
      });

      print('ResAll: ------------------------');
      print(response);

      print('Res: ------------------------');
      print(response.body);

      print(token);

      //create multipart request for POST or PATCH method
      //add text fields
      print(response.statusCode);
      if (response.statusCode == 200) {
        //Get the response from the server
        try{
          if (jsonDecode(response.body)['errors'] == null || jsonDecode(response.body)['errors'] == ''){
            print('success');
            flushBar(AppLocalizations.of(context!)!.translate('Your request is added'));
            return true;
          }else{
            flushBar(jsonDecode(response.body)['errors']);
            return false;
          }
        }catch(e){
          flushBar(e.toString());
          return false;
        }
      } else {
        flushBar(jsonDecode(response.body)['Errors']);
        return false;
        print(response.statusCode);
      }
    }catch(e){
      flushBar(e.toString());
      return false;
    }
  }

  Future addViewCar(id) async{
    try{
      var  apiUrl =Uri.parse('$_baseUrl/CarSell/CarSellViewers_Create');
     print('t');
      Map mapDate = {
          "carSellId": id,
          "fbKey": deviceId,
      };
      print('Req: ------------------------');
      print(jsonEncode(mapDate));
      http.Response response = await http.post(apiUrl,body:jsonEncode(mapDate),headers: {
        //"Accept-Language": LocalizationService.getCurrentLocale().languageCode,
        "Accept": "application/json",
        "content-type": "application/json",
        "Authorization": token,
      });

      print('ResAll: ------------------------');
      print(response);

      print('Res: ------------------------');
      print(response.body);

      print(token);

      //create multipart request for POST or PATCH method
      //add text fields

      print(response.statusCode);
      if (response.statusCode == 200) {
        //Get the response from the server
        try{
          if (jsonDecode(response.body)['errors'] == null || jsonDecode(response.body)['errors'] == ''){
            print('success');
            //flushBar(AppLocalizations.of(context!)!.translate('Your request is added'));
            return true;
          }else{
           // flushBar(jsonDecode(response.body)['errors']);
            return false;
          }
        }catch(e){
          //flushBar(e.toString());
          return false;
        }
      } else {
        //flushBar(jsonDecode(response.body)['Errors']);
        return false;
        print(response.statusCode);
      }
    }catch(e){
      //flushBar(e.toString());
      return false;
    }

  }
  Future addViewCarBoard(id) async{
    try{
      var  apiUrl =Uri.parse('$_baseUrl/CarKey/CarSellViewers_Create');
      print('t');
      Map mapDate = {
        "relatedId": id,
        "fbKey": deviceId,
      };
      print('Req: ------------------------');
      print(jsonEncode(mapDate));
      http.Response response = await http.post(apiUrl,body:jsonEncode(mapDate),headers: {
        //"Accept-Language": LocalizationService.getCurrentLocale().languageCode,
        "Accept": "application/json",
        "content-type": "application/json",
        "Authorization": token,
      });

      print('ResAll: ------------------------');
      print(response);

      print('Res: ------------------------');
      print(response.body);

      print(token);

      //create multipart request for POST or PATCH method
      //add text fields

      print(response.statusCode);
      if (response.statusCode == 200) {
        //Get the response from the server
        try{
          if (jsonDecode(response.body)['errors'] == null || jsonDecode(response.body)['errors'] == ''){
            print('success');
            //flushBar(AppLocalizations.of(context!)!.translate('Your request is added'));
            return true;
          }else{
            // flushBar(jsonDecode(response.body)['errors']);
            return false;
          }
        }catch(e){
          //flushBar(e.toString());
          return false;
        }
      } else {
        //flushBar(jsonDecode(response.body)['Errors']);
        return false;
        print(response.statusCode);
      }
    }catch(e){
      //flushBar(e.toString());
      return false;
    }

  }

}