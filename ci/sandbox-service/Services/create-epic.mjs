import { runCommand } from "./helper.mjs";

const createEpicBranch = (epicBranchName) => {
  runCommand(`
        git checkout develop
        git pull --all
        git checkout -b ${epicBranchName}
        git push origin ${epicBranchName}
    `);
};

const fetchEverything = () => runCommand(`git pull --all`);

const findBranchCommits = (branchName, commitCounts) =>
  runCommand(
    `git log ${branchName} -${commitCounts} --pretty=format:"%h"`
  ).split("\n");

const findSharedCommits = (
  epicBranchName,
  chosenCommit = "",
  commitCounts = 50
) => {
  if (chosenCommit) return chosenCommit;
  const epicCommits = findBranchCommits(epicBranchName, commitCounts);
  const masterCommits = findBranchCommits("master", commitCounts);
  chosenCommit = epicCommits.find((cm) => masterCommits.includes(cm));
  return findSharedCommits(epicBranchName, chosenCommit, commitCounts + 50);
};

const createTag = (epicBranchName) => {
  const sharedCommit = findSharedCommits(epicBranchName);
  const tag = `${epicBranchName}-${sharedCommit}`;
  runCommand(`
        git checkout ${sharedCommit}
        git tag "${tag}"
        git push origin "${tag}"
    `);

  console.log(`New created tag is: ${tag} | Commit ref: ${sharedCommit}`);
};

export { createEpicBranch, fetchEverything, createTag };

console.log(createTag("ar-128766"));
