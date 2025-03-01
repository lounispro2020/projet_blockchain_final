import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const voting = buildModule("VotingModule", (m) => {
  const voteContract = m.contract("VotingSessions");

  return { voteContract };
});

export default voting;