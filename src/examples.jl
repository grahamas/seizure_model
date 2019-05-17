function get_example(example_name)
    examples = Dict(
                    "tuan" => tuan
                    )
    return examples[example_name]
end

examples_path = "src/examples"
top_level = walkdir(examples_path) |> first
examples = joinpath.(examples_path, top_level[3])
include.(examples)
