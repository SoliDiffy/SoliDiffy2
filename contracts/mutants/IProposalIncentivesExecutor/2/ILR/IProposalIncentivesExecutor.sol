// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.7.5;

interface IProposalIncentivesExecutor {
  function execute(
    address[5] memory aTokenImplementations,
    address[5] memory variableDebtImplementation
  ) external;
}
