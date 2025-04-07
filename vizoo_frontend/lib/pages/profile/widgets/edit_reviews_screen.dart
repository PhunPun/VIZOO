import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vizoo_frontend/apps/colors/colors.dart';

class EditReviewScreen extends StatefulWidget {
  final Map<String, dynamic> review;
  const EditReviewScreen({super.key, required this.review});

  @override
  State<EditReviewScreen> createState() => _EditReviewScreenState();
}

class _EditReviewScreenState extends State<EditReviewScreen> {
  int selectedRating = 0;
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedRating = widget.review['rating'];
    commentController.text = widget.review['comment'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(MyColor.white),
      appBar: AppBar(
        backgroundColor: Color(MyColor.white),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(MyColor.black)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.review['location']} ${widget.review['duration']}',
          style: TextStyle(
            color: Color(MyColor.black),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SvgPicture.asset(
              'assets/icons/logo.svg',
              height: 32,
              width: 32,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/vungtau.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/logo_avt.svg',
                  height: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.review['duration']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(MyColor.black),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Color(MyColor.pr1),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('Hoạt động: 15')),
                      Expanded(child: Text('Nơi ở: Nhà nghỉ kim phung')),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('Bữa ăn: 9')),
                      Expanded(
                          child: Text('Chi phí: 2.500.000đ')),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('Số người: 1')),
                      Expanded(child: Text('Đánh giá địa điểm: 4*')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chất lượng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _ratingText(selectedRating),
                  style: TextStyle(
                    color: Color(MyColor.pr5),
                    fontSize: 14,
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      selectedRating = index + 1;
                    });
                  },
                  icon: Icon(
                    Icons.star,
                    size: 32,
                    color: index < selectedRating
                        ? Colors.amber
                        : Color(MyColor.grey),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(MyColor.grey)),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: commentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Hãy chia sẻ nhận xét của bạn',
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(MyColor.white),
                  foregroundColor: Color(MyColor.pr5),
                  side: BorderSide(color: Color(MyColor.pr5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Gửi đánh giá'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _ratingText(int rating) {
    switch (rating) {
      case 5:
        return 'Tuyệt vời';
      case 4:
        return 'Rất tốt';
      case 3:
        return 'Tốt';
      case 2:
        return 'Tạm được';
      case 1:
        return 'Tệ';
      default:
        return '';
    }
  }
}
