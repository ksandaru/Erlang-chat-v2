%%%-------------------------------------------------------------------
%%% @author Kanishka Bandara
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. Sep 2022 11:24 AM
%%%-------------------------------------------------------------------
-module(chat_server_supervisor).
-author("Kanishka Bandara").

%% API

-behaviour(supervisor).

-export([start_link/0, init/1, start_link_shell2/0]).

start_link_shell2()->
  {ok, Pid2}= supervisor:start_link({global,?MODULE}, ?MODULE,[]),
  unlink(Pid2).

start_link() ->
  supervisor:start_link({global, ?MODULE}, ?MODULE, []).

init([]) ->
  io:format("~p / ~p starting chat server supervisor...~n", [{global, ?MODULE}, self()]),
  AChild = #{id => 'chat_server1',
    start => {'chat_server', start_link, []},
    restart => permanent,
    shutdown => infinity,
    type => worker,
    modules => ['chat_server']},

  {ok, {#{strategy => one_for_one,
    intensity => 5,
    period => 30},
    [AChild]}
  }.