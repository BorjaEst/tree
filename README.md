# tree 
Library to build id trees based in erlang maps.


## Installation
Create your own project with rebar3.
 ```sh
 $ rebar3 new app yourapp
 ```

Then in your project path find rebar.config file and add enn as dependency under the deps key:
```erlang
{deps, 
    [
        {enn, {git, "https://github.com/BorjaEst/tree.git", {tag, "<version>"}}}
    ]}.
```

Then using compile command, rebar3 will fetch the defined dependencies and compile them as well for your application.
```sh
$ rebar3 compile
```

At the end for making a release you first need to create your release structure and then making a release with following commands.
```sh
$ rebar3 new release yourrel
$ rebar3 release
```

>You can find more information about dependencies in [rebar3 - dependencies](https://www.rebar3.org/docs/dependencies). 


## Usage
Load the app using your prefered method. For example in the project folder executing  rebar3 shell:
```sh
$ rebar3 shell
1>
```


All user functions are defined inside the module [src/tree](./src/tree.erl), however here is an example:



### Create your first tree 
First of all I would need a base tree, you can use the function `new/0`:
```erl
1> tree:new().
#{}
```
> As you can see, the return is an empty map, so you can just start working with `#{}` or your own tree from scratch (for example `#{a => #{b=>#{}}}`).

### Start adding branches to the tree
You can add branches indicating the key where to attach the next branch:
```erl
2> tree:add(a, b, #{a=>#{}}).
#{a => #{b => #{}}}
3> tree:add(b, c, #{a=>#{b=>#{}}}).
#{a => #{b => #{c => #{}}}}
```
> If the key does not exists on the tree an error {badkey, Key} is raised.

```erl
4> tree:add(b, c, #{a=>#{}}).
** exception error: {badkey,b}
```
> There is a special branch called 'root'. Use it to add branches at the toop of the tree.


### Cut tree branches using the key
Then you should gerenate your training, for example:
```erl
5> tree:cut(a, #{a=>#{b=>#{}}}).
#{a => #{}}
```
> Note the key is not deleted but the subtree reduced to `#{}`. If the key does not exist on the tree an error {badkey, Key} is raised.
```erl
6> tree:cut(z, #{a=>#{b=>#{}}}).
** exception error: {badkey,z}
```

### Find the path from the root to your key
The main usage of the library is to represent a tree and easily find path you can do it using `path/2` function:
```erl
7> tree:path(c, #{a=>#{b=>#{c=>#{}}}}).
[a,b,c]
```

### Find out if a key belongs to that tree
You can check if a key belongs to the tree using `is_key/2` function:
```erl
8> tree:is_key(b, #{a=>#{b=>#{}}}).    
true
9> tree:is_key(z, #{a=>#{b=>#{}}}).
false
```


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.


### Improvement ideas and requests
The main idea behind is to provide a representation and an easy/fast way to update trees. If you think you can improve timing or behaviour you are welcomed.

There are extension functions to serialise/deserialise from lists. Useful when the representation of your tree is at the form [{Child, Parent}] so new branches can be added very fast just appending new elements to the list.


## License
This software is under [GPL-3.0](https://www.gnu.org/licenses/gpl-3.0.en.html) license.

