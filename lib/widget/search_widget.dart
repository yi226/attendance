import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchWidget extends StatefulWidget {
  final double? height; // 高度
  final double? width; // 宽度
  final String? hintText; // 输入提示
  final ValueChanged<String>? onEditingComplete; // 编辑完成的事件回调

  const SearchWidget({
    Key? key,
    this.height,
    this.width,
    this.hintText,
    this.onEditingComplete,
  }) : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// 清除查询关键词
  clearKeywords() {
    controller.text = '';
    widget.onEditingComplete?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      var width = widget.width ?? constrains.maxWidth / 1.5; // 父级宽度
      return SizedBox(
        width: width,
        child: CupertinoTextField(
            controller: controller,
            placeholder: "关键字搜索",
            style: Theme.of(context).textTheme.bodyMedium,
            prefix: const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Icon(Icons.search),
            ),
            suffix: IconButton(
              icon: const Icon(Icons.close),
              onPressed: clearKeywords,
              splashColor: Colors.grey,
            ),
            onChanged: (v) {
              widget.onEditingComplete?.call(controller.text);
            }),
      );
    });
  }
}
