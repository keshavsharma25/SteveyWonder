import { useEffect } from "react";
import { useScaffoldContractRead } from "../scaffold-eth";
import { Address } from "viem";
import { ContractName } from "~~/utils/scaffold-eth/contract";

type Option = {
  name: ContractName;
  address: Address | undefined;
};

export const useBalanceOfOwner = ({ name, address }: Option) => {
  const {
    data: addrBalance,
    refetch,
    status,
  } = useScaffoldContractRead({
    contractName: name,
    functionName: "balanceOf",
    args: [address],
    watch: true,
    cacheTime: 5_000,
  });

  useEffect(() => {
    refetch();
  }, [name, refetch]);

  return { addrBalance, status };
};
