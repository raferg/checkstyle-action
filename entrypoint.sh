#!/bin/sh

echo "Running checkstyle"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

if [ -n "${INPUT_PROPERTIES_FILE}" ]; then
  OPT_PROPERTIES_FILE="-p ${INPUT_PROPERTIES_FILE}"
fi

wget -O - -q https://github.com/checkstyle/checkstyle/releases/download/checkstyle-${INPUT_CHECKSTYLE_VERSION}/checkstyle-${INPUT_CHECKSTYLE_VERSION}-all.jar > /checkstyle.jar

mkdir -p output
touch output/checkstyle.log
touch output/checkstyleStats.log

for input_file in ${INPUT_FILE_LIST}; do
  if [[ "${input_file: -5}" == ".java" ]]; then
    exec java -jar /checkstyle.jar "${input_file}" -c "${INPUT_CHECKSTYLE_CONFIG}" ${OPT_PROPERTIES_FILE} -f xml \
     | reviewdog -f=checkstyle \
          -name="${INPUT_TOOL_NAME}" \
          -reporter="${INPUT_REPORTER:-github-pr-check}" \
          -filter-mode="${INPUT_FILTER_MODE:-added}" \
          -fail-on-error="${INPUT_FAIL_ON_ERROR:-false}" \
          -level="${INPUT_LEVEL}" \
     | grep ': error:' \
     >> output/checkstyle.log
  else 
    echo "Does not match \"${input_file}\""
  fi
done

total_violations=$(wc -l output/checkstyle.log)
echo "Total violations found: ${total_violations}"
echo ::set-output name=total_volations::"${total_violations}"

echo "${GITHUB_ACTOR}, ${GITHUB_BASE_REF}, ${GITHUB_RUN_NUMBER}, ${GITHUB_SHA}" >> output/checkstyleStats.log
grep -oE ': error:.*' output/checkstyle.log | cut -d'(' -f1 | sort | uniq -c >> output/checkstyleStats.log
