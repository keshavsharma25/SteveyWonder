import { useEffect, useState } from "react";
import Image from "next/image";
import { useScaffoldContractRead } from "~~/hooks/scaffold-eth";

type Props = {
  tokenId: bigint;
};

export const ShowSteveyTokenURI = ({ tokenId }: Props) => {
  const [tokenURI, setTokenURI] = useState<string>("");

  const { data: tokenURIStevey } = useScaffoldContractRead({
    contractName: "SteveyWonder",
    functionName: "tokenURI",
    args: [tokenId],
  });

  useEffect(() => {
    let _tokenURIStevey = tokenURIStevey as string;
    console.log(_tokenURIStevey);
    _tokenURIStevey = _tokenURIStevey?.split("data:application/json;base64,")[1];

    if (tokenURIStevey != undefined) {
      const jsonString = Buffer.from(_tokenURIStevey as string, "base64").toString("utf-8");
      const parseTokenURI = JSON.parse(jsonString);
      console.log(parseTokenURI);
      setTokenURI(parseTokenURI.image);
    }
  }, [tokenURIStevey]);

  return (
    <>
      <Image src={`data:image/svg+xml;base64,${tokenURI}`} alt="SteveyWonder Token" width={250} height={250} />
    </>
  );
};
