from __future__ import print_function

import pprint
from datetime import datetime

import mlbgame


class Status():
    # `H: < Team > , R: < Runs > , H: < Hits > , E: < Errors > , A: < Team > , R: < Runs > , H: < Hits > , E: < Errors > , I: < Inning > , S: < Status >`

    def __init__(self, team):
        self.team = team
        self.away_team = ''
        self.away_runs = 0
        self.away_hits = 0
        self.away_errors = 0
        self.home_team = ''
        self.home_runs = 0
        self.home_hits = 0
        self.home_errors = 0
        self.curr_inning = 0
        self.game_status = ''

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
            return 'Failed to get game data'

        if not sb:
            return 'No game today'

        # pp = pprint.PrettyPrinter()
        # print(f"sb = {pp.pprint(sb)}")
        game_id = sb['game_id']

        ret = f"Home: {game_id['home_team']:10} "
        ret += f"R: {game_id['home_team_runs']:02}, "
        ret += f"H: {game_id['home_team_hits']:02}, "
        ret += f"E: {game_id['home_team_errors']}\n"
        ret += f"Away: {game_id['away_team']:10} "
        ret += f"R: {game_id['away_team_runs']:02}, "
        ret += f"H: {game_id['away_team_hits']:02}, "
        ret += f"E: {game_id['away_team_errors']}\n"
        ret += f"Status: {game_id['game_status']}"

        return ret


def main():
    """Main function"""
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
