import { useDeployedContractInfo, useScaffoldContractRead } from "../scaffold-eth";
import { Option } from "~~/types/steveywonder";

type Options = {
  option: Option;
  mainTokenId: number;
};

export const useCurrentAccessory = ({ option, mainTokenId }: Options) => {
  const { data: optionInfo } = useDeployedContractInfo(option);

  const { data: tokenId, status } = useScaffoldContractRead({
    contractName: "SteveyWonder",
    functionName: "getActiveAccessory",
    args: [optionInfo?.address as string | undefined, BigInt(mainTokenId)],
  });

  return { tokenId, status };
};
