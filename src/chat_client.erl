%%%-------------------------------------------------------------------
%%% @author Kanishka Bandara
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(chat_client).

-behaviour(gen_server).

-export([start_link/0, stop/0, send_message/3, receive_message/3]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-record(chat_client_state, {messages,receivers,senders,sent,received}).

%%%===================================================================
%%% Spawning and gen_server implementation
%%%===================================================================

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

send_message(From,To, Msg)->
  gen_server:cast({?MODULE, node()},{send_message,From,To,Msg}).

receive_message(From, To, Msg)->
  gen_server:call({?MODULE, list_to_atom(To)},{receive_message,From,To,Msg}).

stop()->
  gen_server:stop(?MODULE).

init([]) ->
  io:format("~p connected...",[node()]),
  {ok, #chat_client_state{
    messages = [],
    sent=[],
    received = [],
    receivers = [],
    senders = []
  }}.

%%handle_call(_Request, _From,State = #chat_server_state{}) ->
%%  {reply,ok, State}.

handle_cast({send_message,From,To,Msg}, State = #chat_client_state{receivers = Receivers,messages = Messages, sent =Sent}) ->
  chat_server:send_message_server(From,To,Msg),
  receive_message(From,To,Msg),
  {noreply, State#chat_client_state{receivers = [To|Receivers], messages = [Msg|Messages], sent=[Msg|Sent]}}.

handle_call({receive_message,From,To,Msg},_From, State = #chat_client_state{received=Received, senders = Senders}) ->
  chat_server:receive_message_server(From,To,Msg),
  io:format("I'm ~p and sent by ~p Message: ~p~n",[To, From,Msg]),
  {reply,ok, State#chat_client_state{ received =[Msg|Received], senders = [From|Senders]}}.

%%handle_cast(_Request, State = #chat_client_state{}) ->
%%  {noreply, State}.

handle_info(_Info, State = #chat_client_state{}) ->
  {noreply, State}.

terminate(_Reason, _State = #chat_client_state{}) ->
  ok.

code_change(_OldVsn, State = #chat_client_state{}, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
