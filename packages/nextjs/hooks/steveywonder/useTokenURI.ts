import { useEffect, useState } from "react";
import { useScaffoldContractRead } from "../scaffold-eth";
import { ContractName } from "~~/utils/scaffold-eth/contract";

type options = {
  contractName: ContractName;
  tokenId: bigint;
};

export const useTokenURI = ({ contractName, tokenId }: options) => {
  const [tokenURI, setTokenURI] = useState<string>("");

  const { data: uri, isLoading } = useScaffoldContractRead({
    contractName,
    functionName: "tokenURI",
    args: [tokenId],
  });

  useEffect(() => {
    let _tokenURI = uri as string;
    console.log(_tokenURI);
    _tokenURI = _tokenURI?.split("data:application/json;base64,")[1];

    if (uri != undefined) {
      const jsonString = Buffer.from(_tokenURI as string, "base64").toString("utf-8");
      const parseTokenURI = JSON.parse(jsonString);
      console.log(parseTokenURI);
      setTokenURI(parseTokenURI.image);
    }
  }, [uri]);

  return { tokenURI, isLoading };
};