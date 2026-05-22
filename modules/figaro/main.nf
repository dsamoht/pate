process FIGARO {

    tag meta.run_id[0]

    container params.figaro_container

    publishDir "${params.output}/figaro", mode: 'copy', pattern: "*filterAndTrimParameters.txt"

    input:
    tuple val(meta), path(reads, stageAs: "figaro_input/*")

    output:
    tuple val(meta), path("*filterAndTrimParameters.txt")

    script:
    def length = meta.figaro_length[0]
    def run_id = meta.run_id[0]
    def python_cmd = """import json
    with open('figaro_out/trimParameters.json') as json_file:
        data = json.load(json_file)
    print(data[0]['trimPosition'][0])
    print(data[0]['trimPosition'][1])
    print(data[0]['maxExpectedError'][0])
    print(data[0]['maxExpectedError'][1])
    """
    """
    figaro.py -a ${length} -f 1 -r 1 -i figaro_input -o figaro_out
    python -c "${python_cmd}" > ${run_id}_filterAndTrimParameters.txt
    """

}