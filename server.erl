%%%-------------------------------------------------------------------
%%% @author MN
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. Jul 2020 3:53 AM
%%%-------------------------------------------------------------------
-module(server).
-author("MN").

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

% gen_server events
-export([s_accident/2,s_close_to_car/2,s_fallen_car/1,s_into_range/1,s_light/2,s_out_of_range/1,start/0,car_finish_bypass/1,car_finish_turn/1]).

-define(SERVER, ?MODULE).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).
start() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
  {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).
init([]) ->
  ets:new(cars,[set,public,named_table]),

  %Pid = spawn(cars,start,[1]),
  %io:format("AAAAAAAAAAAAAAAAAAAAAAAAAA  ~p~n",[Pid]),
  %ets:insert(cars,{Pid,[{1200,120},left,r1]}),
  %ets:insert(cars,{1,[{160, 120},left,r1]}),

%c(main).
%c(server).
%c(cars).
%c(sensors).
%c(traffic_light).
%main:start().

  ets:new(junction,[set,public,named_table]),


   traffic_light:start(r1a,{{r1,a},[{1153,120}]}),
   traffic_light:start(r1b,{{r1,b},[{938,120}]}),
   ets:insert(junction,{{r1,t},[{799,120},nal]}),
   traffic_light:start(r1c,{{r1,c},[{658,120}]}),
   ets:insert(junction,{{r1,s},[{442,120},nal]}),
   traffic_light:start(r1d,{{r1,d},[{302,120}]}),
   traffic_light:start(r1e,{{r1,e},[{164,120}]}),
   traffic_light:start(r2e,{{r2,e},[{128,81}]}),
   traffic_light:start(r2f,{{r2,f},[{128,381}]}),
   traffic_light:start(r2o,{{r2,o},[{128,621}]}),
   traffic_light:start(r3f,{{r3,f},[{92,418}]}),
   ets:insert(junction,{{r3,r},[{232,418},nal]}),
   traffic_light:start(r3g,{{r3,g},[{372,418}]}),
   traffic_light:start(r3h,{{r3,h},[{589,418}]}),
   traffic_light:start(r3i,{{r3,i},[{728,418}]}),
   ets:insert(junction,{{r3,u},[{867,418},nal]}),
   traffic_light:start(r3j,{{r3,j},[{1091,418}]}),
   traffic_light:start(r4l,{{r4,l},[{625,820}]}),
   traffic_light:start(r4m,{{r4,m},[{625,689}]}),
   traffic_light:start(r4h,{{r4,h},[{625,457}]}),
   traffic_light:start(r4c,{{r4,c},[{625,157}]}),
   traffic_light:start(r5k,{{r5,k},[{1090,655}]}),
   traffic_light:start(r6k,{{r6,k},[{1122,689}]}),
   traffic_light:start(r6j,{{r6,j},[{1122,457}]}),
   traffic_light:start(r6a,{{r6,a},[{1122,157}]}),
   traffic_light:start(r7l,{{r7,l},[{659,787}]}),
   traffic_light:start(r8d,{{r8,d},[{266,157}]}),
   traffic_light:start(r9o,{{r9,o},[{93,655}]}),
   traffic_light:start(r9n,{{r9,n},[{373,655}]}),
   traffic_light:start(r9m,{{r9,m},[{590,655}]}),
   traffic_light:start(r10i,{{r10,i},[{763,381}]}),
   ets:insert(junction,{{r12,p},[{902,622},nal]}),
   ets:insert(junction,{{r12,q},[{902,753},nal]}),
   traffic_light:start(r14n,{{r14,n},[{407,689}]}),
   traffic_light:start(r14g,{{r14,g},[{407,457}]}),
   traffic_light:start(r18b,{{r18,b},[{902,81}]}),

  cars:start(a,10,[{1200,93},left,r1]),
%  cars:start(b,20,[{1000,93},left,r1]),

  roadGraph(),
  {ok, #state{}}.

%% Events
s_light(Who,{R,J}) -> gen_server:cast(?MODULE,{light,Who,{R,J}}).
s_close_to_car(Who,OtherCar) -> gen_server:cast(?MODULE,{ctc,Who,OtherCar}).
s_fallen_car(Who) -> gen_server:cast(?MODULE,{fallen,Who}).
s_accident(Who,Car2) -> gen_server:cast(?MODULE,{acc,Who,Car2}).
s_out_of_range(Who) -> gen_server:cast(?MODULE,{oor,Who}).
s_into_range(Who) -> gen_server:cast(?MODULE,{inr,Who}).
car_finish_bypass(Who) -> cars:f_bypass(Who).
car_finish_turn(Who) -> cars:f_turn(Who).

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
  {reply, Reply :: term(), NewState :: #state{}} |
  {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_call(_Request, _From, State) ->
  {reply, ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
%handle_cast(_Request, State) ->
%  {noreply, State}.

handle_cast({light,Who,{_,J}}, State) -> % TODO: decide whether the car turns left, right or straight

 List =  digraph:out_neighbours(get(graph),J),
  E = lists:nth(rand:uniform(length(List)),List),
  {Dir, Road} = getEdgeLabel(get(graph),digraph:out_edges(get(graph),J),E),
 % cars:turn(Who, {up, r6}),
  cars:turn(Who, {Dir, Road}),
  {noreply, State};


handle_cast({ctc,Who,OtherCar}, State) -> % TODO: decide whether the car slows down or bypasses the other car
  Bool = checkBypass(Who,OtherCar,ets:first(cars)),
  case Bool of
    true -> cars:bypass(Who);
    _ -> case sys:get_state(OtherCar) of
           stopping -> cars:stop(Who);
           _ -> cars:slow_down(Who)
         end
  end,

  {noreply, State};
handle_cast({fallen,Who}, State) -> % TODO: if car process has fallen with an error, bring it back up if possible
  {noreply, State};
handle_cast({acc,Who,Car2}, State) -> % TODO: remove involved cars from street
  {noreply, State};
handle_cast({oor,Who}, State) -> % TODO: send car details to new server and remove car from ETS
  {noreply, State};
handle_cast({inr,Who}, State) -> % TODO: enter car details to ETS
  {noreply, State}. %%%



%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_info(_Info, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(_Reason, _State) ->
  ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
  {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

checkBypass(_,_,'$end_of_table') -> true;
checkBypass(Who,OtherCar,FirstKey) -> [{_,[{X,Y},Dir1,R]}] =  ets:lookup(cars,Who),
  [{P2,[{X2,Y2},_,R2]}] = ets:lookup(cars,FirstKey),
  if
    R == R2, P2 /= Who, P2 /= OtherCar ->
      case Dir1 of
        left -> D = X-X2, if
                            D =< 200 , D >= 0 -> false;
                            true -> checkBypass(Who,OtherCar,ets:next(cars,P2))
                          end;

        right ->  D = X2-X, if
                              D =< 200 , D >= 0 -> false;
                              true -> checkBypass(Who,OtherCar,ets:next(cars,P2))
                            end;
        up ->  D = Y-Y2, if
                           D =< 200 , D >= 0 -> false;
                           true -> checkBypass(Who,OtherCar,ets:next(cars,P2))
                         end;
        down -> D = Y2-Y, if
                            D =< 200 , D >= 0 -> false;
                            true -> checkBypass(Who,OtherCar,ets:next(cars,P2))
                          end
      end;

    true -> checkBypass(Who,OtherCar,ets:next(cars,FirstKey))
  end.

roadGraph()->
  G =  digraph:new(),
  digraph:add_vertex(G,a),
  digraph:add_vertex(G,b),
  digraph:add_vertex(G,c),
  digraph:add_vertex(G,d),
  digraph:add_vertex(G,e),
  digraph:add_vertex(G,f),
  digraph:add_vertex(G,g),
  digraph:add_vertex(G,h),
  digraph:add_vertex(G,i),
  digraph:add_vertex(G,j),
  digraph:add_vertex(G,k),
  digraph:add_vertex(G,l),
  digraph:add_vertex(G,m),
  digraph:add_vertex(G,n),
  digraph:add_vertex(G,o),
  digraph:add_vertex(G,p),
  digraph:add_vertex(G,q),
  digraph:add_vertex(G,r),
  digraph:add_vertex(G,s),
  digraph:add_vertex(G,t),
  digraph:add_vertex(G,u),
  digraph:add_vertex(G,"out1"),
  digraph:add_vertex(G,"out4"),
  digraph:add_vertex(G,"out6"),
  digraph:add_vertex(G,"out3"),
  digraph:add_vertex(G,"out5"),
  digraph:add_vertex(G,"out12"),
  digraph:add_vertex(G,"out2"),
  digraph:add_vertex(G,"out16"),
  digraph:add_vertex(G,"in2"),
  digraph:add_vertex(G,"in6"),
  digraph:add_vertex(G,"in9"),
  digraph:add_vertex(G,"in14"),
  digraph:add_vertex(G,"in4"),
  digraph:add_vertex(G,"in6"),
  digraph:add_vertex(G,"in1"),
  digraph:add_vertex(G,"in18"),
  digraph:add_edge(G,a,b,{left,r1}),
  digraph:add_edge(G,a,"out6",{up,r6}),
  digraph:add_edge(G,b,t,{left,r1}),
  digraph:add_edge(G,t,i,{down,r10}),
  digraph:add_edge(G,t,l,{left,r1}),
  digraph:add_edge(G,c,"out4",{up,r4}),
  digraph:add_edge(G,c,s,{left,r1}),
  digraph:add_edge(G,s,"out16",{up,r16}),
  digraph:add_edge(G,s,d,{left,r1}),
  digraph:add_edge(G,d,e,{left,r1}),
  digraph:add_edge(G,e,"out1",{left,r1}),
  digraph:add_edge(G,e,f,{down,r2}),
  digraph:add_edge(G,f,r,{right,r3}),
  digraph:add_edge(G,f,o,{down,r2}),
  digraph:add_edge(G,r,g,{right,r3}),
  digraph:add_edge(G,r,d,{up,r8}),
  digraph:add_edge(G,g,h,{right,r3}),
  digraph:add_edge(G,h,i,{right,r3}),
  digraph:add_edge(G,h,l,{up,r4}),
  digraph:add_edge(G,i,u,{right,r3}),
  digraph:add_edge(G,u,j,{right,r3}),
  digraph:add_edge(G,u,p,{down,r12}),
  digraph:add_edge(G,j,"out3",{right,r3}),
  digraph:add_edge(G,j,a,{up,r6}),
  digraph:add_edge(G,k,j,{up,r6}),
  digraph:add_edge(G,k,"out5",{right,r5}),
  digraph:add_edge(G,p,k,{right,r5}),
  digraph:add_edge(G,p,q,{down,r12}),
  digraph:add_edge(G,q,l,{left,r7}),
  digraph:add_edge(G,q,"out12",{down,r12}),
  digraph:add_edge(G,l,m,{up,r4}),
  digraph:add_edge(G,m,h,{up,r4}),
  digraph:add_edge(G,n,m,{right,r9}),
  digraph:add_edge(G,n,g,{up,r14}),
  digraph:add_edge(G,o,n,{right,r9}),
  digraph:add_edge(G,o,"out2",{down,r2}),

  put(graph,G).

getEdgeLabel(_,[],_) -> io:format("error");
getEdgeLabel(G,[H|T],V) ->
  {_,_,V2,Label} = digraph:edge(G,H),
  case V == V2 of
    true -> Label;
    _ -> getEdgeLabel(G,T,V)
  end.




