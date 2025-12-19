"use client";

import { useReadContract, useWriteContract, useSimulateContract } from "wagmi";
import { smartFlowContractConfig } from "../abi/smartFlowContractConfig";

export const SMARTFLOW_ADDRESS = "0xE9628076ABbe13523e86A8A0DA557Ca085e273d5";
export const FLOW_TOKEN_ADDRESS = "0xb00C1FC2cc2bf408Aa431b7b8D8c6128F0E8CC48";

export function useGetThreshold() {
  return useReadContract({
    ...smartFlowContractConfig,
    functionName: "threshold",
  });
}

export function useGetPrice() {
  return useReadContract({
    ...smartFlowContractConfig,
    functionName: "getLatestPrice",
    // query: {
    //   refetchInterval: 30_000, // cada 30 segundos (high RPC consumption)
    // },
  });
}

export function useClaimMyReward() {
  const simulation = useSimulateContract({
    ...smartFlowContractConfig,
    functionName: "claimMyReward",
  });

  const { writeContract, isPending, error, data: hash } = useWriteContract();

  const claim = () => {
    if (!simulation.data) return;
    writeContract(simulation.data.request);
  };

  return {
    claim,
    isPending,
    hash,
    error,
    canClaim: Boolean(simulation.data),
    simulationError: simulation.error,
  };
}

export function useLastClaimAt(address?: `0x${string}`) {
  return useReadContract({
    ...smartFlowContractConfig,
    functionName: "lastClaimAt",
    args: address ? [address] : undefined,
    query: {
      enabled: Boolean(address),
    },
  });
}

export function useCooldown() {
  return useReadContract({
    ...smartFlowContractConfig,
    functionName: "cooldown",
  });
}
