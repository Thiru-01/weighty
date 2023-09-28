import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weighty/components/avatars.dart';
import 'package:weighty/components/card.dart';
import 'package:weighty/components/graph.dart';
import 'package:weighty/models/wei_model.dart';
import 'package:weighty/screens/tracker_add_page.dart';
import 'package:weighty/services/firestore_service.dart';
import 'package:weighty/utils/constants.dart';
import 'package:weighty/utils/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user = FirebaseAuth.instance.currentUser;
  ValueNotifier<bool> refershNotifier = ValueNotifier<bool>(false);
  List<String> filterTypes = [
    "This Month",
    "Last Month",
    "Last 2 Month",
    "All"
  ];

  late RxString selectedValue;
  GlobalKey futureKey = GlobalKey();
  RxList<ReportDate> reportData = <ReportDate>[].obs;
  @override
  void initState() {
    selectedValue = filterTypes[0].obs;
    super.initState();
  }

  Future<List<WeiData>> fetchData(BuildContext context) async {
    FirestoreFetcherService fetcherService = FirestoreFetcherService(context);
    if (user != null) {
      reportData.value = await fetcherService.getGraphData(
          path: user!.uid, selectedFilter: selectedValue.value);
      //Refreshing the Rx-List
      reportData.refresh();
      return await fetcherService.getData(
          path: user!.uid, selectedFilter: selectedValue.value);
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBar(context),
      floatingActionButton: FloatingActionButton(
          isExtended: true,
          onPressed: () async {
            await Get.to(() => const AddTracker()); //Wait for back stage
            refershNotifier.value = !refershNotifier.value;
            printInfo(info: "Back to main");
          },
          child: const Icon(Icons.add)),
      body: ValueListenableBuilder(
          //Used to make futurebuilder to rebuild for everytime
          valueListenable: refershNotifier,
          builder: (context, snapshot, _) {
            return FutureBuilder<List<WeiData>>(
                key: futureKey,
                future: fetchData(context),
                initialData: const [],
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return loadingComponent();
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          AgeReport(
                            filterNames: filterTypes,
                            currentlySelected:
                                filterTypes.indexOf(selectedValue.value),
                            sourceContet: reportData,
                            onSelected: (selectedValue) async {
                              //Make the list of report data to null because it will shows the previous content
                              reportData.value = [];
                              reportData.refresh();
                              this.selectedValue.value = selectedValue;
                              //Making the future builder to rebuild
                              refershNotifier.value = !refershNotifier.value;
                            },
                          ),
                          for (WeiData dataModel in snapshot.data ?? [])
                            WeiCard(
                              model: dataModel,
                              onNavigationEnd: () => refershNotifier.value =
                                  !refershNotifier.value,
                            )
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                });
          }),
    );
  }

  Widget loadingComponent() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: SizeConstrains.DEFAULT_PADDING * 3),
            child: Text(
              "Loading and building data of your body",
              style: TextStyle(
                  fontSize: calculateFontSize(factor: 18, context: context),
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).primaryColor),
            ),
          )
        ],
      ),
    );
  }

  AppBar homeAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text(
        "Home",
        style: TextStyle(color: Colors.white),
      ),
      actions: const [],
      leading: Avatar(
        url: user?.photoURL,
      ),
      leadingWidth: calculateWidth(factor: 0.07, context: context),
    );
  }
}
