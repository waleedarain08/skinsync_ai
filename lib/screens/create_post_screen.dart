import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../widgets/bottom_sheets/media_picker_button.dart';
import '../widgets/dialogs/image_source_dialog.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/post_image_preview.dart';
import '../widgets/post_video_preview.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];
  XFile? _selectedVideo;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages(ImageSource source) async {
    if (source == ImageSource.gallery) {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
          _selectedVideo = null;
        });
      }
    } else {
      final XFile? image = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.front,
      );
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
          _selectedVideo = null;
        });
      }
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    final XFile? video = await _picker.pickVideo(source: source);
    if (video != null) {
      setState(() {
        _selectedVideo = video;
        _selectedImages.clear();
      });
    }
  }

  Future<void> _showPickerOptions({required bool isVideo}) async {
    final source = await showImageSourceDialog(
      context,
      title: isVideo ? 'Select Video Source' : 'Select Image Source',
    );
    if (source != null) {
      if (isVideo) {
        _pickVideo(source);
      } else {
        _pickImages(source);
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeVideo() {
    setState(() {
      _selectedVideo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(showTitle: true, title: "Create Post"),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.w(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "Post Title (Optional)",
                hintStyle: CustomFonts.grey16w500,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: CustomColors.purpleColor),
                ),
              ),
              style: CustomFonts.black18w600,
            ),
            SizedBox(height: context.h(20)),

            // Content Field
            TextField(
              controller: _contentController,
              maxLines: 8,
              minLines: 5,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                hintStyle: CustomFonts.grey14w400,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.r(12)),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.r(12)),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.r(12)),
                  borderSide: const BorderSide(color: CustomColors.purpleColor),
                ),
                fillColor: Colors.grey.shade50,
                filled: true,
              ),
              style: CustomFonts.black14w400,
            ),
            SizedBox(height: context.h(20)),

            // Media Selection Row
            Row(
              children: [
                MediaPickerButton(
                  onTap: () => _showPickerOptions(isVideo: false),
                  icon: Icons.image_rounded,
                  label: "Images",
                  color: Colors.blue.shade400,
                ),
                SizedBox(width: context.w(15)),
                MediaPickerButton(
                  onTap: () => _showPickerOptions(isVideo: true),
                  icon: Icons.videocam_rounded,
                  label: "Video",
                  color: Colors.red.shade400,
                ),
              ],
            ),
            SizedBox(height: context.h(20)),

            // Media Preview
            PostImagePreview(images: _selectedImages, onRemove: _removeImage),
            PostVideoPreview(video: _selectedVideo, onRemove: _removeVideo),

            SizedBox(height: context.h(30)),

            CustomButton(
              text: "Post",
              onPressed: () {
                if (_contentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter some content")),
                  );
                  return;
                }
                // TODO: Implement post creation logic
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
