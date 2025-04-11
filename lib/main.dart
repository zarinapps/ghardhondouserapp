import 'package:ebroker/app/register_cubits.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat/chat_audio/globals.dart';
import 'package:ebroker/ui/screens/chat_new/message_types/registerar.dart';
import 'package:flutter/material.dart';

//////////////
///V-1.2.2///
////////////

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initApp();
}

class EntryPoint extends StatefulWidget {
  const EntryPoint({
    super.key,
  });
  @override
  EntryPointState createState() => EntryPointState();
}

class EntryPointState extends State<EntryPoint> {
  @override
  void initState() {
    super.initState();
    ChatMessageHandler.handle();
    ChatGlobals.init();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        ...RegisterCubits().register(),
      ],
      child: Builder(
        builder: (BuildContext context) {
          return const App();
        },
      ),
    );
  }
}
