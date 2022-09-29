%%%-------------------------------------------------------------------
%%% @author Kanishka Bandara
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. Sep 2022 9:44 PM
%%%-------------------------------------------------------------------
-module(database_server).

-behaviour(gen_server).

-export([start_link/0, store/4, getalldb/1, delete/1, init/1]).
-export([ handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-record(database_server_state, {}).

%%%===================================================================
%%% Spawning and gen_server implementation
%%%===================================================================

start_link() ->
  gen_server:start_link({local,?MODULE}, ?MODULE, [], []).

init([]) ->
  process_flag(trap_exit, true),
  io:format("~p (~p) starting database server...~n", [{local, ?MODULE}, self()]),
  {ok, #database_server_state{}}.


store(Node, Username, Location, Gender) ->
  gen_server:call({database_server,'john@DESKTOP-RD414DV'}, {store_db, Node, Username, Location, Gender}).


%%Node arg should be string("nmn@...")
getalldb(Node) ->
  gen_server:call({database_server,'john@DESKTOP-RD414DV'}, {get_all_db, Node}).
delete(Node) ->
  gen_server:call({database_server,'john@DESKTOP-RD414DV'}, {delete, Node}).

handle_call({store_db, Node, Username, Location, Gender}, _From, State = #database_server_state{}) ->
  database_logic:store_db(Node, Username, Location, Gender),
  N = Node ++" User details are saved!",
  {reply, {ok, N}, State};

handle_call({get_all_db, Node}, _From, State = #database_server_state{}) ->
  Y = database_logic:get_all_dbe(Node),
  {_, [{Name, Location, Gender}]} = Y,
  Z ="SENDER NAME: "++Name++" LOCATION: "++Location++" GENDER: "++Gender,
  {reply, {ok, Z}, State};

handle_call({delete, Node},  _From, State = #database_server_state{}) ->
  database_logic:delete_db(Node),
  M ="Node: " ++Node++ "data deleted!",
  {reply, {ok, M}, State}.

handle_cast(_Request, State = #database_server_state{}) ->
  {noreply, State}.

handle_info(_Info, State = #database_server_state{}) ->
  {noreply, State}.

terminate(_Reason, _State = #database_server_state{}) ->
  ok.

code_change(_OldVsn, State = #database_server_state{}, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

