ERL ?= erl
APP := gen_server_test
REBAR = rebar

.PHONY: eunit

build: clean update_deps compile ct

init: get_deps compile ct

continuous_integration_full_build: distclean clean get_deps compile lock-deps ct

compile:
	$(REBAR) compile

eunit:
	$(REBAR) eunit skip_deps=true

update_deps:
	$(REBAR) update-deps

get_deps:
	$(REBAR) get-deps

clean:
	$(REBAR) clean

reset: clean distclean init

distclean:
	$(REBAR) delete-deps
	rm -rf deps

lock-deps:
	$(REBAR) lock-deps

eunitmake:
	@-mkdir -p .eunit
	erlc +debug_info -I deps/gen_server_app/include -I deps +'{parse_transform, lager_transform}' -DTEST -o .eunit -pa deps/lager/ebin deps/gen_server_app/src/*.erl
	erlc +debug_info -I include -I deps +'{parse_transform, lager_transform}' -DTEST -o .eunit -pa deps/lager/ebin src/*.erl

ct:	eunitmake
	@-mkdir -p logs
	ct_run -noshell -dir test -logdir logs -pa deps/*/ebin -pa ebin -pa .eunit -cover test/coverage.cfg -erl_args -sname gsa_ct -config ../gen_server_node/files/sys 
