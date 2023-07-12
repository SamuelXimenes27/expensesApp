import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/app/shared/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/constants/routes.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String? userName;
  bool switchValue = false;

  String? totalValueString = '';
  String? totalValuePlusHideMoneyString = '';
  String? totalTransactionsString = '';
  String? totalDeposits = '';
  String? totalBuys = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadSwitchValue();
    getTotalValue();
    getTotalValuePlusHideMoney();
    getItemCountByCurrentUser();
    getDepositsCountByCurrentUser();
    getBuysCountByCurrentUser();
  }

  Future<void> loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? '';
      });
    }
  }

  Future<void> saveSwitchValue(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('usePhoto', value);
  }

  Future<void> loadSwitchValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      switchValue = prefs.getBool('usePhoto') ?? false;
    });
  }

  Future<void> getTotalValue() async {
    double totalValue = 0;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('transactionCollection')
        .get();

    for (var doc in querySnapshot.docs) {
      double value = doc['value'] as double;

      if (value < 0) {
        value = -value;
      }

      totalValue += value;
    }

    setState(() {
      totalValueString = totalValue.toStringAsFixed(0);
    });
  }

  Future<void> getTotalValuePlusHideMoney() async {
    double total = 0;
    double totalValue = 0;
    double hideMoneyValue = 0;

    QuerySnapshot querySnapshotTotalValue = await FirebaseFirestore.instance
        .collection('transactionCollection')
        .get();

    for (var doc in querySnapshotTotalValue.docs) {
      double value = doc['value'] as double;

      totalValue += value;
    }

    QuerySnapshot querySnapshotHideMoney = await FirebaseFirestore.instance
        .collection('hideMoneyCollection')
        .get();

    for (final collection in querySnapshotHideMoney.docs) {
      final collectionData = collection.data() as Map<String, dynamic>;
      final stats = collectionData['stats'] as String;

      if (stats != 'closed') {
        final transactions = collectionData['transactions'] as List<dynamic>;

        for (final transaction in transactions) {
          final transactionData = transaction as Map<String, dynamic>;
          final type = transactionData['type'] as String;

          if (type == 'add') {
            final value = transactionData['value'];
            setState(() {
              hideMoneyValue += value;
            });
          }
        }
      }
    }

    setState(() {
      total = totalValue + hideMoneyValue;
      totalValuePlusHideMoneyString = total.toStringAsFixed(0);
    });
  }

  Future<void> getItemCountByCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userName = user?.displayName;

    if (userName != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('transactionCollection')
          .where('user', isEqualTo: userName)
          .get();

      int itemCount = querySnapshot.docs.length;
      setState(() {
        totalTransactionsString = itemCount.toString();
      });
    }
  }

  Future<void> getDepositsCountByCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userName = user?.displayName;

    if (userName != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('transactionCollection')
          .where('type', isEqualTo: 'Ganhos')
          .where('user', isEqualTo: userName)
          .get();

      int itemCount = querySnapshot.docs.length;
      setState(() {
        totalDeposits = itemCount.toString();
      });
    }
  }

  Future<void> getBuysCountByCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userName = user?.displayName;

    if (userName != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('transactionCollection')
          .where('value', isLessThan: 0)
          .where('user', isEqualTo: userName)
          .get();

      int itemCount = querySnapshot.docs.length;
      setState(() {
        totalBuys = itemCount.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Expanded(flex: 2, child: _TopPortion()),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  children: [
                    Text(
                      userName!,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Estatísticas',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCard(
                            title: 'Valor Total Movimentado',
                            value: '€' + totalValueString!,
                          ),
                          _buildCard(
                            title: 'Valor Atual + Caixinhas',
                            value: '€' + totalValuePlusHideMoneyString!,
                          ),
                          _buildCard(
                            title: 'Transações',
                            value: totalTransactionsString!,
                          ),
                          _buildCard(
                            title: 'Depositos',
                            value: totalDeposits!,
                          ),
                          _buildCard(
                            title: 'Compras',
                            value: totalBuys!,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Configurações',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Switch(
                          value: switchValue,
                          onChanged: (value) {
                            setState(() {
                              switchValue = value;
                            });
                            saveSwitchValue(value);
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text('UTILIZAR A FOTO NAS TRANSAÇÕES'),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // const Expanded(child: SizedBox()),
                    FloatingActionButton.extended(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacementNamed(
                            context, RoutesConst.login);
                      },
                      heroTag: 'logout',
                      elevation: 0,
                      backgroundColor: ColorsConst.primary,
                      label: const Text("Logout"),
                      icon: const Icon(Icons.logout),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildCard({required String title, required String value}) {
  return SizedBox(
    width: 120,
    child: Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.abc),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({Key? key}) : super(key: key);

  final List<ProfileInfoItem> _items = const [
    ProfileInfoItem("Posts", 900),
    ProfileInfoItem("Followers", 120),
    ProfileInfoItem("Following", 200),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      constraints: const BoxConstraints(maxWidth: 400),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _items
            .map((item) => Expanded(
                    child: Row(
                  children: [
                    if (_items.indexOf(item) != 0) const VerticalDivider(),
                    Expanded(child: _singleItem(context, item)),
                  ],
                )))
            .toList(),
      ),
    );
  }

  Widget _singleItem(BuildContext context, ProfileInfoItem item) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              item.value.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Text(
            item.title,
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
}

class ProfileInfoItem {
  final String title;
  final int value;
  const ProfileInfoItem(this.title, this.value);
}

class _TopPortion extends StatefulWidget {
  const _TopPortion({
    Key? key,
  }) : super(key: key);

  @override
  State<_TopPortion> createState() => _TopPortionState();
}

enum ImageUploadState {
  awaiting,
  ready,
  uploading,
  completed,
}

class _TopPortionState extends State<_TopPortion> {
  File? userImage;
  String? updatedImageUrl;
  String? userName;
  ImageUploadState uploadState = ImageUploadState.awaiting;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? '';
        userImage = user.photoURL != null ? File(user.photoURL!) : null;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        userImage = File(pickedImage.path);
        uploadState = ImageUploadState.ready;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final fileName = '${user.uid}.jpg';

        setState(() {
          uploadState = ImageUploadState.uploading;
        });

        final imageUrl =
            await uploadImageToFirebaseStorage(userImage!, fileName);
        await saveImageURLToUserProfile(imageUrl);

        setState(() {
          updatedImageUrl = imageUrl;
          uploadState = ImageUploadState.completed;
        });
      }
    }
  }

  Future<String> uploadImageToFirebaseStorage(
      File imageFile, String fileName) async {
    try {
      final ref =
          firebase_storage.FirebaseStorage.instance.ref().child(fileName);
      await ref.putFile(imageFile);
      final imageUrl = await ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      return '';
    }
  }

  Future<void> saveImageURLToUserProfile(String imageUrl) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePhotoURL(imageUrl);
      }
    } catch (e) {
      print('Erro ao salvar o URL da imagem no perfil do usuário: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 50),
          decoration: const BoxDecoration(
            color: ColorsConst.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                InkWell(
                  onTap: uploadState == ImageUploadState.awaiting
                      ? () => _pickImage()
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      image: userImage != null
                          ? DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(userImage!.path),
                            )
                          : null,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: userImage == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.file_download_rounded,
                              color: Colors.white,
                            ),
                            Text(
                              'Escolha uma foto',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : Container(),
                ),
                userImage != null
                    ? Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: uploadState == ImageUploadState.awaiting
                              ? () => _pickImage()
                              : null,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            child: const Icon(Icons.edit),
                          ),
                        ),
                      )
                    : Container(),
                if (uploadState == ImageUploadState.uploading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 30, left: 5),
          child: Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.close),
              color: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ],
    );
  }
}
