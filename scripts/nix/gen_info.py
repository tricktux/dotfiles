from __future__ import print_function

import pprint
from datetime import datetime

import mlbgame


class Status:
    # `H: < Team > , R: < Runs > , H: < Hits > , E: < Errors > , A: < Team > , R: < Runs > , H: < Hits > , E: < Errors > , I: < Inning > , S: < Status >`

    def __init__(self, team):
        self.team = team

    def get(self, year, month, day):
        """
        year: yyyy integer format
        month: mm integer format
        day: dd integer format

        Returns string: with formatted output
        """

        try:
            games = mlbgame.day(
                year, month, day, home=self.team, away=self.team)
        except:
            print("Failed to get scoreboard data")
            return

        if not games:
            print(f"\tNo games today for the '{self.team}'")
            return

        for scoreboard in games:
            gid = scoreboard.game_id
            ret = "**************\n"
            ret += f"Game ID: {gid}\n"
            ret += f"Start Time: {scoreboard.game_start_time}\n"
            ret += f"Home: {scoreboard.home_team:10} "
            ret += f"R: {scoreboard.home_team_runs:02}, "
            ret += f"H: {scoreboard.home_team_hits:02}, "
            ret += f"E: {scoreboard.home_team_errors}\n"
            ret += f"Away: {scoreboard.away_team:10} "
            ret += f"R: {scoreboard.away_team_runs:02}, "
            ret += f"H: {scoreboard.away_team_hits:02}, "
            ret += f"E: {scoreboard.away_team_errors}\n"
            ret += f"Status: {scoreboard.game_status}\n"
            ret += str(mlbgame.box_score(gid).print_scoreboard())
            ret += "\n**************\n"
            players = mlbgame.players(gid)
            ret += "Home team players:\n"
            for player in players.home_players:
                ret += f"\t{player.first} {player.last} ({player.position})\n"
            ret += "Away team players:\n"
            for player in players.away_players:
                ret += f"\t{player.first} {player.last} ({player.position})\n"
            # TODO: Team stats
            print(ret)


def main():
    """Main function"""
    dates = mlbgame.important_dates()
    print(f"Important Dates:\n*******\n{dates}\n********")
    team = "Rays"
    year = int(datetime.now().strftime("%Y"))
    month = int(datetime.now().strftime("%m"))
    day = int(datetime.now().strftime("%d")) - 1
    print(f"Games for:\n\t{month}/{day}/{year}")
    status = Status(team)
    status.get(year, month, day)


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

if __name__ == "__main__":
    main()
