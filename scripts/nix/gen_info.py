from __future__ import print_function

import pprint
from datetime import datetime

import mlbgame


class Status():
    # `H: < Team > , R: < Runs > , H: < Hits > , E: < Errors > , A: < Team > , R: < Runs > , H: < Hits > , E: < Errors > , I: < Inning > , S: < Status >`

    def __init__(self, team):
        self.team = team

    def get(self, year, month, day) -> str:
        """
        year: yyyy integer format
        month: mm integer format
        day: dd integer format

        Returns string: with formatted output
        """

        try:
            sb = mlbgame.game.scoreboard(year,
                                         month,
                                         day,
                                         home=self.team,
                                         away=self.team)
        except:
            return 'Failed to get scoreboard data'

        if not sb:
            return 'No game today'

        # pp = pprint.PrettyPrinter()
        # print(f"sb = {pp.pprint(sb)}")
        game_id = next(iter(sb.values()))

        ret = f"Home: {game_id['home_team']:10} "
        ret += f"R: {game_id['home_team_runs']:02}, "
        ret += f"H: {game_id['home_team_hits']:02}, "
        ret += f"E: {game_id['home_team_errors']}\n"
        ret += f"Away: {game_id['away_team']:10} "
        ret += f"R: {game_id['away_team_runs']:02}, "
        ret += f"H: {game_id['away_team_hits']:02}, "
        ret += f"E: {game_id['away_team_errors']}\n"
        ret += f"Status: {game_id['game_status']}"

        try:
            todays_games = mlbgame.day(year,
                                       month,
                                       day,
                                       home=self.team,
                                       away=self.team)
        except:
            return 'Failed to get day data'

        if not todays_games:
            return 'No games today'

        for game in todays_games:
            gid = game.game_id
            if not gid:
                break
            pp = pprint.PrettyPrinter()
            print(f"gid = {pp.pprint(gid)}")
            # events = mlbgame.game_events(gid)
            # for event in events:
            #     print(f"event = {event.nice_output()}")


        return ret


def main():
    """Main function"""
    # dates = mlbgame.important_dates().nice_output().replace('\n', '\t\n')
    dates = mlbgame.important_dates()
    print(f"Important Dates:\n*******\n{dates}\n********")
    team = "Rays"
    year = int(datetime.now().strftime("%Y"))
    month = int(datetime.now().strftime("%m"))
    day = int(datetime.now().strftime("%d")) - 1
    status = Status(team)
    out = status.get(year, month, day)
    print(out)


# todays_game = mlbgame.day(2021, 10, 3, home='Rays', away='Rays')[0]
# box_score = mlbgame.box_score(todays_game.game_id)
# out = box_score.print_scoreboard()
# print("box_score: ")
# print(out)
# # out = mlbgame.overview(todays_game.game_id)
# # print("box_score: ")
# # print(out)
# sb = mlbgame.game.scoreboard(2021, 10, 3, home='Rays', away='Rays')
# pp = pprint.PrettyPrinter()
# print(f"sb = {pp.pprint(sb)}")

if __name__ == '__main__':
    main()
