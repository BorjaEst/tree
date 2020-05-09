%%%-------------------------------------------------------------------
%%% @author BorjaEst
%%% @doc Build trees based in maps.
%%% There is a special key 'root' which means at the top of the tree. 
%%% @end
%%%-------------------------------------------------------------------
-module (tree).
-include_lib("eunit/include/eunit.hrl").

-export([new/0, is_key/2, path/2, add/3]).

-export_type([key/0]).

-type  key()  :: term().
-type tree()  :: #{key() => tree()}.


%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc Creates a new map tree.
%% @end
%%--------------------------------------------------------------------
-spec new() -> tree().
new() -> #{}.

new_test() ->
    ?assertEqual(#{}, new()).

%%--------------------------------------------------------------------
%% @doc Returns true if the keys exists, otherwise false.
%% @end
%%--------------------------------------------------------------------
-spec is_key(key(), tree()) -> boolean().
is_key(Key, Tree) -> 
    try path(Key, Tree) of 
                           _  -> true
    catch error:{badkey, Key} -> false
    end.

is_key_test() ->
    % Tests conditions when the key is tree member
    ?assertEqual( true, is_key(   a, #{a => #{}})),
    ?assertEqual( true, is_key(root,         #{})),
    ?assertEqual( true, is_key(  ba, test_tree())),
    % Tests conditions when the key is not tree member
    ?assertEqual(false, is_key( '?',         #{})),
    ?assertEqual(false, is_key( '?', #{a => #{}})),
    ?assertEqual(false, is_key( '?', test_tree())),
    % Tests conditions when the tree input is not a map
    ?assertException(error, {badmap,x}, is_key(a, x)). 

%%--------------------------------------------------------------------
%% @doc Finds the tree path for a key.
%% @end
%%--------------------------------------------------------------------
-spec path(key(), tree()) -> [key()].
path(root, Tree) when is_map(Tree) -> [];
path( Key, Tree) when is_map(Tree) -> 
    try find_path(Key, Tree, []) of 
                      _ -> error({badkey, Key})
    catch {path, RPath} -> lists:reverse(RPath)
    end;
path(   _, NoMap) -> error({badmap, NoMap}).

path_test() ->
    % Tests conditions when the key is tree member
    ?assertEqual(    [a], path(   a, #{a => #{}})),
    ?assertEqual(     [], path(root, test_tree())),
    ?assertEqual([b, ba], path(  ba, test_tree())),
    % Tests conditions when the key is not tree member
    ?assertException(error, {badkey,'?'}, path('?',         #{})),
    ?assertException(error, {badkey,'?'}, path('?', #{a => #{}})),
    ?assertException(error, {badkey,'?'}, path('?', test_tree())),
    % Tests conditions when the tree input is not a map
    ?assertException(error, {badmap,x}, path(a, x)).

%%--------------------------------------------------------------------
%% @doc Adds a key into the tree.
%% @end
%%--------------------------------------------------------------------
-spec add(To :: key(), Key :: key(), Tree :: tree()) -> tree().
add(root, Key, Tree) -> add_key(Key, Tree);
add(  To, Key, Tree) -> 
    Add_Key = fun(SubTree) -> add_key(Key, SubTree) end,
    update_with(To, Add_Key, Tree).

add_test() ->
    % Tests conditions when the key is tree member
    ?assertMatch( #{a:=#{b:=#{}}}, add(   a,  b, #{a => #{}})),
    ?assertMatch(#{a:=#{},b:=#{}}, add(root,  b, #{a => #{}})),
    % Tests conditions when the key is not tree member
    ?assertException(error, {badkey,'?'}, add('?', x,         #{})),
    ?assertException(error, {badkey,'?'}, add('?', x, #{a => #{}})),
    ?assertException(error, {badkey,'?'}, add('?', x, test_tree())),
    % Tests conditions when the tree input is not a map
    ?assertException(error, {badmap,x}, add(a, a, x)).


%%%===================================================================
%%% Internal functions
%%%===================================================================

% Throws the path (reversed) of an specific key ---------------------
find_path(Key, Tree, Path) when is_map_key(Key,Tree) -> 
    throw({path, [Key|Path]});
find_path(Key, Tree, Path) -> 
    [find_path(Key, SubT, [K|Path]) || {K,SubT}<-maps:to_list(Tree)].

% Applies a function the subtree of the specified key ---------------
update_with(Key, Fun, Tree) -> 
    updt(path(Key, Tree), Fun, Tree).

updt([K   ], Fun, Tree) -> maps:update_with(K, Fun, Tree);
updt([K|Kx], Fun, Tree) -> Tree#{K:=updt(Kx, Fun, maps:get(K,Tree))}.

% Adds the key to the map if it is not already member ---------------
add_key(Key, Map) when is_map_key(Key, Map) -> Map; % Already inside
add_key(Key, Map)                           -> Map#{Key=>#{}}.


%%====================================================================
%% Eunit white box tests
%%====================================================================

% --------------------------------------------------------------------
% TESTS DESCRIPTIONS -------------------------------------------------

% --------------------------------------------------------------------
% SPECIFIC SETUP FUNCTIONS -------------------------------------------

% --------------------------------------------------------------------
% ACTUAL TESTS -------------------------------------------------------

% --------------------------------------------------------------------
% SPECIFIC HELPER FUNCTIONS ------------------------------------------

% Creates a simple map tree for testing -----------------------------
test_tree() ->
    #{
        a => #{
            aa => #{},
            ab => #{}
        },
        b => #{
            ba => #{},
            bb => #{}
        }
    }.

