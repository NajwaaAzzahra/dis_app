import 'package:dis_app/blocs/photo/photo_bloc.dart';
import 'package:dis_app/blocs/photo/photo_event.dart';
import 'package:dis_app/blocs/photo/photo_state.dart';
import 'package:dis_app/blocs/user/user_bloc.dart';
import 'package:dis_app/blocs/user/user_event.dart';
import 'package:dis_app/blocs/user/user_state.dart';
import 'package:dis_app/controllers/user_controller.dart';
import 'package:dis_app/models/photo_model.dart';
import 'package:dis_app/models/user_model.dart';
import 'package:dis_app/pages/account/photo_desc.dart';
import 'package:dis_app/utils/constants/blank_post.dart';
import 'package:dis_app/utils/constants/blank_sell.dart';
import 'package:dis_app/pages/account/form_sell.dart';
import 'package:dis_app/pages/account/postSection.dart';
import 'package:dis_app/pages/account/profileHeader.dart';
import 'package:dis_app/pages/account/sectionToggle.dart';
import 'package:dis_app/pages/account/sellSection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/photo_controller.dart';
import '../../utils/constants/colors.dart';

enum SellFilter { all, available, sold }

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isSellSelected = true;
  SellFilter selectedFilter = SellFilter.all;
  List<String> sellImagePaths = [];
  List<String> postImagePaths = [];

  @override
  void initState() {
    super.initState();
  }

  void _toggleSection(bool isSell) {
    setState(() {
      isSellSelected = isSell;
    });
  }

  void _selectFilter(SellFilter filter) {
    setState(() {
      selectedFilter = filter;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _showUploadOptions(image);
    }
  }

  void _showUploadOptions(XFile imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Upload To"),
          content: const Text("Where do you want to upload this image?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadContentPage(
                      imagePath: imageFile.path,
                    ),
                  ),
                ).then((_) {
                  if (isSellSelected) {
                    context.read<PhotoBloc>().add(ListPhotoEvent());
                  }
                });
              },
              child: const Text("Sell"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) =>
                          PhotoBloc(photoController: PhotoController()),
                      child: PostFormPhotoScreen(
                        imageFile: imageFile,
                        isFromCamera: false,
                      ),
                    ),
                  ),
                ).then((_) {
                  if (!isSellSelected) {
                    context.read<PhotoBloc>().add(ListPhotoEvent());
                  }
                });
              },
              child: const Text("Post"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DisColors.white,
      body: Column(
        children: [
          BlocProvider(
            create: (context) =>
                UserBloc(userController: UserController())..add(UserGetEvent()),
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserSuccess) {
                  return ProfileHeader(
                    user: User.fromJson(state.data!),
                    onPickImage: _pickImage,
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          SectionToggle(
            isSellSelected: isSellSelected,
            onToggle: _toggleSection,
          ),
          Expanded(
            child: BlocProvider(
              create: (context) => PhotoBloc(photoController: PhotoController())
                ..add(ListPhotoEvent(page: 1, size: 10)),
              child: BlocBuilder<PhotoBloc, PhotoState>(
                builder: (context, state) {
                  if (state is PhotoLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is PhotoByAccountSuccess) {
                    final sellImages = (state.sell['data'] as List)
                        .where((element) => element['type'] == "sell")
                        .toList();
                    final postImages = (state.post['data'] as List)
                        .where((element) => element['type'] == "post")
                        .toList();

                    return RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<PhotoBloc>()
                            .add(ListPhotoEvent(page: 1, size: 10));
                      },
                      child: ListView(
                        physics:
                            const AlwaysScrollableScrollPhysics(), // Wajib ditambahkan
                        children: [
                          if (isSellSelected)
                            sellImages.isEmpty
                                ? DisBlankSell(onUpload: _pickImage)
                                : SellSection(
                                    sellPhotos: sellImages
                                        .map((image) =>
                                            SellPhoto.fromJson(image))
                                        .toList(),
                                    selectedFilter: selectedFilter,
                                    onFilterSelect: _selectFilter,
                                  )
                          else
                            postImages.isEmpty
                                ? DisBlankPost(onUpload: _pickImage)
                                : PostSection(
                                    postPhotos: postImages
                                        .map((image) =>
                                            PostPhoto.fromJson(image))
                                        .toList(),
                                  ),
                        ],
                      ),
                    );
                  }
                  return const Center(child: Text("Photos not available"));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
