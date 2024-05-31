import 'package:auctionapp/const/colors.dart';
import 'package:auctionapp/utils/server/Firebase_store_fetch.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  FirestoreService firestoreService = FirestoreService();
  late List<double> numbers = [];
  Future<List<GridItem>> getAuctionStatistics() async {
    List<double> stats = await firestoreService.getAuctionStats();
    numbers = stats;
    List<GridItem> gridItems = [
      GridItem(Icons.align_vertical_bottom_outlined, 'Total Number of Bids in this app', stats[0].toString()),
      GridItem(Icons.assignment_outlined, 'Currently running Number of bids', stats[1].toString()),
      GridItem(Icons.brightness_high_outlined, 'Total Number of Completed Bids', stats[2].toString()),
      GridItem(Icons.price_change_rounded, 'Total Auction Value Amount', stats[3].toString()),
    ];

    return gridItems;
  }

  List<Color> gradientColors = [
    Colors.greenAccent.shade200,
    AppColor.green,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30,),
              Row(
                children: const [
                  Icon(Icons.menu_rounded, color: Colors.white,),
                  SizedBox(width: 10,),
                  Text("Dashboard", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),),
                ],
              ),
              Container(
                child: FutureBuilder<List<GridItem>>(
                  future: getAuctionStatistics(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(
                        color: AppColor.green,
                      ));
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error loading data'));
                    } else {
                      List<GridItem> gridItems = snapshot.data ?? [];
                      return Column(
                        children: [
                          SizedBox(
                            height: 360,
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // Number of columns
                              ),
                              itemCount: gridItems.length,
                              itemBuilder: (context, index) {
                                return Container(
                                    margin: EdgeInsets.all(8),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColor.secondary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(gridItems[index].icon, color: AppColor.primary, size: 30,),
                                        SizedBox(height: 10,),
                                        Text(gridItems[index].title, style: TextStyle(fontSize: 13),),
                                        SizedBox(height: 10,),
                                        Text(gridItems[index].number, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)
                                      ],
                                    )
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: const [
                              Icon(Icons.insert_chart_outlined, size: 30, color: Colors.white,),
                              SizedBox(width: 8,),
                              Text("Summary Charts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),)
                            ],
                          ),
                          SizedBox(height: 15,),
                          Container(
                            width: double.infinity,
                            height: 400,
                            child: numbers.isNotEmpty?LineChart(
                              mainData(),
                            ): Container(),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10,
      color: AppColor.secondary,
    );
    Widget text;
    switch (value.toInt()) {
      case 2:
        text = const Text('Day 1', style: style);
        break;
      case 5:
        text = const Text('Day 5', style: style);
        break;
      case 8:
        text = const Text('Day 8', style: style);
        break;
      case 11:
        text = const Text('Day 11', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      color: AppColor.secondary,
      fontSize: 10,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = '1 bids';
        break;
      case 5:
        text = '5 bids';
        break;
      case 10:
        text = '10 bids';
        break;
      case 15:
        text = '15 bids';
        break;
      case 20:
        text = '20 bids';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: AppColor.secondary,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: AppColor.secondary,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 12,
      minY: 0,
      maxY: 20,
      lineBarsData: [
        LineChartBarData(
          spots:  [
            FlSpot(0, 0),
            FlSpot(1, numbers[1]),
            FlSpot(5, numbers[1]),
            FlSpot(8, numbers[0]),
            FlSpot(11, numbers[1]),
            FlSpot(12, numbers[0]),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class GridItem {
  final IconData icon;
  final String title;
  final String number;

  GridItem(this.icon, this.title, this.number);
}


