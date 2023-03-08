// Zet dit in de initState:
// SoccerSimulator().start(
//       speed: 100,
//       teama: team1,
//       teamb: team2,
//       func: (state, event) {
//         if (event != null) {
//           if (event["event"] == SoccerEvent.Goal) {
//             if (event["team"] == team1) {
//               setState(() {
//                 score1++;
//               });
//             }
//             if (event["team"] == team2) {
//               setState(() {
//                 score2++;
//               });
//             }
//           }
//         }
//         setState(() {
//           gameminute = event["gametime"];
//         });
//       });

// import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math' as math;

enum SoccerState {
  Starting,
  Started,
  Pauzing,
  Pauzed,
  Resuming,
  Ending,
  Ended,
  None
}

enum SoccerEvent {
  None,
  FreeKick,
  Goal,
  ThrowIn,
  Attack,
  Injury,
  Corner,
  Substitution,
  YellowCard,
  RedCard,
  Penalty,
  NearMiss
}

class Team {
  int strength;
  String name;
  String? code;
  Team({this.name = "", this.strength = 0, this.code});
  @override
  String toString() {
    // TODO: implement toString
    return "$name";
  }
}

class SoccerSimulator {
  Function? eventFunc;
  Team team1 = Team(name: "Holland", strength: 10);
  Team team2 = Team(name: "Brasil", strength: 10);
  Timer? gameTimer;
  int minute = 0;
  SoccerState state = SoccerState.None;

  start(
      {required int speed,
      required Team teama,
      required Team teamb,
      required Function func}) {
    team1 = teama;
    team2 = teamb;
    eventFunc = func;
    gameTimer = Timer.periodic(Duration(milliseconds: speed), (timer) {
      if (minute > 45 && minute < 60) {
        state = SoccerState.Pauzed;
      } else {
        state = SoccerState.Started;
      }
      if (minute == 0) state = SoccerState.Starting;
      if (minute == 45) state = SoccerState.Pauzing;
      if (minute == 60) state = SoccerState.Resuming;
      if (minute == 105) state = SoccerState.Ending;

      if (minute >= 105) {
        state = SoccerState.Ended;
        gameTimer?.cancel();
        //minute = 0;
      }
      // determine a random event for the minute
      SoccerEvent event = SoccerEvent
          .values[math.Random().nextInt(SoccerEvent.values.length - 1) + 1];

      Team team = math.Random().nextInt(2) == 1 ? team1 : team2;
      Team otherteam = team == team1 ? team2 : team1;

      if ((minute < 15 && (math.Random().nextInt(10) % 6 == 0)) ||
          (minute >= 15 &&
              minute < 45 &&
              (math.Random().nextInt(10) % 5 == 0)) ||
          (minute >= 60 &&
              minute < 90 &&
              (math.Random().nextInt(10) % 4 == 0)) ||
          (minute >= 90 &&
              minute < 105 &&
              (math.Random().nextInt(10) % 3 == 0))) {
        if (event == SoccerEvent.Penalty) {
          if (math.Random().nextInt(10) % 4 == 0) {
            int number = math.Random().nextInt(5);
            int player = number + 6;
            eventFunc?.call(state, {
              "event": event,
              "gametime": minute >= 45 && minute < 60
                  ? 45
                  : minute > 60
                      ? minute - 15
                      : minute,
              "team": team,
              "player": player
            });
            if (math.Random().nextInt(10) % 2 == 0) {
              eventFunc?.call(state, {
                "event": SoccerEvent.Goal,
                "gametime": minute >= 45 && minute < 60
                    ? 45
                    : minute > 60
                        ? minute - 15
                        : minute,
                "team": team,
                "player": player
              });
            } else {
              eventFunc?.call(state, {
                "event": SoccerEvent.NearMiss,
                "gametime": minute >= 45 && minute < 60
                    ? 45
                    : minute > 60
                        ? minute - 15
                        : minute,
                "team": team,
                "player": player
              });
            }
          }
        } else {
          if (event == SoccerEvent.Goal) {
            if (math.Random().nextInt(10) %
                    (team.strength > otherteam.strength ? 2 : 3) ==
                0) {
              eventFunc?.call(state, {
                "event": event,
                "gametime": minute >= 45 && minute < 60
                    ? 45
                    : minute > 60
                        ? minute - 15
                        : minute,
                "team": team,
                "player": math.Random().nextInt(5) + 6
              });
            } else {
              eventFunc?.call(state, {
                "event": SoccerEvent.NearMiss,
                "gametime": minute >= 45 && minute < 60
                    ? 45
                    : minute > 60
                        ? minute - 15
                        : minute,
                "team": team,
                "player": math.Random().nextInt(5) + 6
              });
            }
          } else {
            eventFunc?.call(state, {
              "event": event,
              "gametime": minute >= 45 && minute < 60
                  ? 45
                  : minute > 60
                      ? minute - 15
                      : minute,
              "team": team,
              "player": math.Random().nextInt(11) + 1
            });
          }
        }
      }

      eventFunc?.call(state, {
        "gametime": minute >= 45 && minute < 60
            ? 45
            : minute > 60
                ? minute - 15
                : minute
      });
      minute++;
    });
  }
}

main() {
  SoccerSimulator().start(
      speed: 1000,
      teama: Team(name: "Holland", strength: 20),
      teamb: Team(name: "Brasil", strength: 40),
      func: (state, event) {
        print("$event");
      });
}
