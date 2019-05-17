function get_example(example_name)
    examples = Dict(
                    "tuan" => tuan
                    )
    return examples[example_name]
end

path_to_here = "src"
examples_path = "examples"
top_level = walkdir(joinpath(path_to_here, examples_path)) |> first
examples = joinpath.(examples_path, top_level[3])
include.(examples)
