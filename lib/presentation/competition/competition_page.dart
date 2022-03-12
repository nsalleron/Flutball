import 'package:flutball/domain/entities/competition.dart';
import 'package:flutball/domain/entities/team.dart';
import 'package:flutball/presentation/competition/components/circular_loading.dart';
import 'package:flutball/presentation/competition/logic/competition_cubit.dart';
import 'package:flutball/presentation/competition/logic/team_cubit.dart';
import 'package:flutball/presentation/competition/views/club_team.dart';
import 'package:flutball/presentation/competition/views/competition_header.dart';
import 'package:flutball/presentation/competition/views/players.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({Key? key}) : super(key: key);

  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  @override
  Widget build(BuildContext teamPageContext) {
    final List<Widget> widgets = <Widget>[];
    return BlocConsumer<CompetitionCubit, CompetitionState>(
      listener: (BuildContext context, CompetitionState state) {
        if (state is CompetitionSuccess && state.competitions.isNotEmpty) {
          context
              .read<TeamCubit>()
              .fetchBestTeam(competition: state.competitions.first);
        }
      },
      builder: (BuildContext context, CompetitionState competitionState) {
        final PageController pageController = PageController(initialPage: 0);

        if (competitionState is CompetitionSuccess) {
          widgets.addAll(
            competitionState.competitions.map(
              (currentCompetition) => SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CompetitionHeader(comp: currentCompetition),
                    BlocBuilder<TeamCubit, TeamState>(
                      builder: (buildContext, state) {
                        if (state is TeamLoading) {
                          return const _TeamLoadingPage();
                        }
                        if (state is TeamSuccess) {
                          return _TeamSuccessPage(team: state.team);
                        }
                        if (state is TeamFailed) {
                          return _TeamPageFailed(
                            competition: currentCompetition,
                            errorMessage: state.errorMessage,
                          );
                        }
                        if (state is TeamNoMatchesYet) {
                          return const _TeamNoMatchesYet();
                        }
                        return const SizedBox.shrink();
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        }
        return PageView(
          controller: pageController,
          children: [...widgets],
          onPageChanged: (page) => competitionState is CompetitionSuccess
              ? context.read<TeamCubit>().fetchBestTeam(
                    competition: competitionState.competitions[page],
                  )
              : null,
        );
      },
    );
  }
}

class _TeamPageFailed extends StatelessWidget {
  const _TeamPageFailed({
    Key? key,
    required this.competition,
    required this.errorMessage,
  }) : super(key: key);

  final Competition competition;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              errorMessage,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 0),
            child: RefreshIndicator(
              onRefresh: () => context
                  .read<TeamCubit>()
                  .fetchBestTeam(competition: competition),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SvgPicture.asset(
                  'assets/svg/failed.svg',
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _TeamNoMatchesYet extends StatelessWidget {
  const _TeamNoMatchesYet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No winner yet ! :(',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _TeamLoadingPage extends StatelessWidget {
  const _TeamLoadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CircularLoading();
  }
}

class _TeamSuccessPage extends StatelessWidget {
  const _TeamSuccessPage({Key? key, required this.team}) : super(key: key);

  final Team team;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        ClubTeam(team: team),
        if (team.squad?.isNotEmpty == true)
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Current squad : ',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Players(squad: team.squad!)
              ],
            ),
          )
        else
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No selection for now!',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SvgPicture.asset(
                      'assets/svg/nosquad.svg',
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                )
              ],
            ),
          )
      ],
    );
  }
}
