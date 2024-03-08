import { useScaffoldContractRead } from "../scaffold-eth";

export const useTokenBoundAddress = (tokenId: number) => {
  const { data: tba } = useScaffoldContractRead({
    contractName: "SteveyWonder",
    functionName: "getTBAAddress",
    args: [BigInt(tokenId)],
  });

  return { tba };
};
