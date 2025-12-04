// @BAKE gcc $@ -o $*.out -ltree-sitter -ltree-sitter-markdown

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tree_sitter/api.h>

extern const TSLanguage *tree_sitter_markdown(void);

int main(int argc, char * argv[]) {
    if (argc < 2) { return 1; }

	FILE* f = fopen(argv[1], "r");
	if(!f){ return 2; }

	fseek(f, 0, SEEK_END);
	int flen = ftell(f);
	rewind(f);
	char fstr[flen+1];
	fstr[flen] = '\00';
	fread(fstr, flen, sizeof(char), f);
    const char *source_code = fstr;

    TSParser *parser = ts_parser_new();
    ts_parser_set_language(parser, tree_sitter_markdown());

    TSTree *tree = ts_parser_parse_string(parser, NULL, source_code, strlen(source_code));
    TSNode root_node = ts_tree_root_node(tree);

    char *tree_string = ts_node_string(root_node);
    printf("%s\n", tree_string);
    free(tree_string);

    ts_tree_delete(tree);
    ts_parser_delete(parser);
    return 0;
}
